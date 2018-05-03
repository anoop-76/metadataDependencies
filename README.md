# Metadata Dependencies

Sample wrapper around [Dependencies API](https://releasenotes.docs.salesforce.com/en-us/summer18/release-notes/rn_metadata_metadatacomponentdependency.htm) Pilot.

The wrapper make it even easier to query and produces the output in human readable format.

1) It will create a list of dependencies in a [csv](https://github.com/anoop-76/metadataDependencies/blob/master/Metadata_Dependencies.png) under 'My Personal Documents'

2) Email the dependencies in a .csv document to the user running.


<a href="https://githubsfdeploy.herokuapp.com">
   <img alt="Deploy to Salesforce"
		 src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Usage & Sample

Once you have deployed in your Org.

1) Find metadata that depends on 'Order' object:

```
DependencyService.withRefTo('Order');
```

2) Find metadata that depends on an object's field by Id:

```
DependencyService.withRefToById('00N3000000Bact4EAB');
```

3) Find metadata that depends on a ApexClass:

```
DependencyService.withRefTo('Utils');
```

4) Run with query:

```
String queryStr = 'SELECT MetadataComponentName, MetadataComponentType,RefMetadataComponentName,RefMetadataComponentType FROM  MetadataComponentDependency WHERE RefMetadataComponentName = 'Apttus__APTS_Agreement__c';
DependencyService.withQquery(queryStr); .
```

