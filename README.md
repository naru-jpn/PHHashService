# PHHashService
Calculate hash string for all local images and store them.


## How to use

### Run
Start to calculate hash string for all local images.

```
[[PHHashService sharedService] run];
```

Automatically save calculated data when all procedure finished.

### Store
Store current data if changes to store exist.

```
[[PHHashService sharedService] store];
```

### Clear
Clear all data and cancel procedure.

```
[[PHHashService sharedService] clear];
```

### Get results

#### Get all results

```
NSArray<PHHashedObject *> *hashedObjects = [[PHHashService sharedService] allHashedObjects];
```

#### Get local identifiers for image with hash string

```
NSArray<NSString *> *hashStrings = @[@"hash_string1", @"hash_string2", ...];
NSArray<NSString *> *localIdentifiers = [[PHHashService sharedService] localIdentifiersForHashStrings:hashStrings];
```

