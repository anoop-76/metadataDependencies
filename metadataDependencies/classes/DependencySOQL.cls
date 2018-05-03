// @author anoop.singh
public class DependencySOQL {

	public static final String SOQL = 'SELECT MetadataComponentId, MetadataComponentName, MetadataComponentNamespace, RefMetadataComponentNamespace, MetadataComponentType, RefMetadataComponentName, RefMetadataComponentId, RefMetadataComponentType FROM MetadataComponentDependency';
    public static final String SOQL_REF_NAME = 'SELECT MetadataComponentId, MetadataComponentName, MetadataComponentNamespace, RefMetadataComponentNamespace, MetadataComponentType, RefMetadataComponentName, RefMetadataComponentId, RefMetadataComponentType FROM MetadataComponentDependency WHERE RefMetadataComponentName = {0}';
    public static final String SOQL_REF_ID = 'SELECT MetadataComponentId, MetadataComponentName, MetadataComponentNamespace, RefMetadataComponentNamespace, MetadataComponentType, RefMetadataComponentName, RefMetadataComponentId, RefMetadataComponentType FROM MetadataComponentDependency WHERE RefMetadataComponentId = {0}';
	public static final String SOQL_QUERY = 'SELECT MetadataComponentId, MetadataComponentName, MetadataComponentNamespace, RefMetadataComponentNamespace, MetadataComponentType, RefMetadataComponentName, RefMetadataComponentId, RefMetadataComponentType FROM MetadataComponentDependency WHERE \'{0}\'';

}