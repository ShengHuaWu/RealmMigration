## Realm Lightweight Migration
[_Realm_](https://realm.io) is a cross-platform mobile database solution designed for mobile applications.
It’s fast, lightweight, and quite simple to integrate into your project.
Furthermore, it doesn't rely on _Core Data_ or a _SQLite_ database.
The Realm developers claim that their data storage solution is faster than _SQLite_ as well as _Core Data_.

### Problem
Our company has used _Realm_ as a local data storage in _iOS_.
Recently, I came across a problem after I modified our model's properties.
Our app crashed and _Xcode_'s console output told me `Migration is required due to the following errors:`.
In order to solve this issue, I read _Realm_'s documentations as well as online resources and figured out how to implement several lightweight migrations.

### Solution
Our app crashes because there is a mismatch between what I define in code and the data exists on disk if I had saved any data with the previous model version.
When this happens, an exception will be thrown when I try to open the existing file.
The solution is to define a migration and the associated schema version by creating a `Realm.Configuration` instance.
```
let config = Realm.Configuration(
  // Set the new schema version. This must be greater than the previously used
  // version (if you've never set a schema version before, the version is 0).
  schemaVersion: 1,
  migrationBlock: { migration, oldSchemaVersion in
    if oldSchemaVersion < 1 {
      // Apply any necessary migration logic here.
    }
  })

Realm.Configuration.defaultConfiguration = config
```
The migration block provides all the logic for converting data models from previous schemas to the new schema.

In order to demonstrate the migration process, I create a simple project and it contains only one model called `Person`.
```
class Person: Object {
    dynamic var name = ""
    dynamic var age = 0
}
```
First of all, let's try to add a new `email` property in our `Person` model.
To do this, we simply change the object interface to the following:
```
class Person: Object {
    dynamic var name = ""
    dynamic var age = 0
    dynamic var email = ""
}
```
Because my previous model version doesn't have the `email` property,
I can do the migration by calling `Migration`'s `enumerateObjects` method within the migration block and assign an empty email string to the existing data.
```
if oldSchemaVersion < 1 {
    migration.enumerateObjects(ofType: Person.className()) { (_, newPerson) in
        newPerson?["email"] = ""
    }
}
```
Secondly, I want to rename the `name` property to `fullName`.
The migration can be done by increasing the schema version and invoking `Migration`'s `renameProperty` method inside the migration block.
It's important to make sure that the new models have a property with the new name and don’t have a property with the old name.
```
if oldSchemaVersion < 2 {
    migration.renameProperty(onType: Person.className(), from: "name", to: "fullName")
}
```
Finally, I would like to separate the `fullName` property into `firstName` and `lastName`.
The migration is very similar to what we've done when adding the `email` property.
I enumerate each `Person` and apply any necessary migration logic.
Don't forget to increase the schema version as well.
```
if oldSchemaVersion < 3 {
    migration.enumerateObjects(ofType: Person.className()) { (oldPerson, newPerson) in
        guard let fullname = oldPerson?["fullName"] as? String else {
            fatalError("fullName is not a string")
        }

        let nameComponents = fullname.components(separatedBy: " ")
        if nameComponents.count == 2 {
            newPerson?["firstName"] = nameComponents.first
            newPerson?["lastName"] = nameComponents.last
        } else {
            newPerson?["firstName"] = fullname
        }
    }
}
```
The sample project is [here](https://github.com/ShengHuaWu/RealmMigration).

### Conclusion
Frankly speaking, _Realm_ is a great solution for data storage and its documentations are very comprehensive.
However, there are several things should be noticed when you run a migration.
First, the default property values aren’t applied to new objects or new properties on existing objects during migrations.
Secondly, structuring your migration blocks with non-nested `if (oldSchemaVersion < X)` calls ensures that users will pass through all necessary upgrades,
no matter which schema version they start from.
In addition, you should take care of users who skipped versions of your app.
If you have any comments or questions on this article, please leave a response below. Thank you!
