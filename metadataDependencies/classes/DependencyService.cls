
// @author anoop.singh
public with sharing class DependencyService {

    public static final DependencyService service = new DependencyService();

    private DependencyService() { }

    public static DependencyService withRefTo(String searhStr) {
        withQuery(String.format(DependencySOQL.SOQL_REF_NAME, new String[]{'\''+searhStr+'\''}));
        return service;
    }

    public static DependencyService withRefToById(String searhStr) {
        withQuery(String.format(DependencySOQL.SOQL_REF_ID, new String[]{'\''+searhStr+'\''}));        return service;
    }

    public static DependencyService withQuery(String queryString) {
		System.debug('withQuery queryString=' + queryString);

        ToolingService tooling = new ToolingService();
        ToolingService.QueryResult result = tooling.query(queryString);

        if(result != null) {
            System.debug('QueryResult result=' + result);
            System.debug('QueryResult result.records='+ result.records);
            List<ToolingService.MetadataComponentDependency> dependencies = (List<ToolingService.MetadataComponentDependency>)result.records;
			createCsv(dependencies);
        }
        return service;
    }

    private static void createCsv(List<ToolingService.MetadataComponentDependency> dependencies) {

        if(dependencies == null || dependencies.size() == 0) {
            return;
        }
        integer maxListSize = 0;
        String reportType = '';
        List<String> metadataTypes = new List<String>();
        Map<String, List<ToolingService.MetadataComponentDependency>> metadataTypeMap = new Map<String, List<ToolingService.MetadataComponentDependency>>();
        for(ToolingService.MetadataComponentDependency dependency : dependencies) {

            if(dependency == null) {
                continue;
            }
            System.debug(dependency.metadataComponentType);
			reportType = dependency.refMetadataComponentName;

			List<ToolingService.MetadataComponentDependency> resultList = metadataTypeMap.get(dependency.metadataComponentType);
            if(resultList == null) {
                resultList = new List<ToolingService.MetadataComponentDependency>();
                metadataTypes.add(dependency.metadataComponentType);
            }
            resultList.add(dependency);
            if(resultList.size() > maxListSize)
                maxListSize = resultList.size();
            metadataTypeMap.put(dependency.metadataComponentType, resultList);
        }
        metadataTypes.sort();

        String csvColumnHeader = '';
	    List<String> csvRowValues = new List<String>();

        for(String metadataType : metadataTypes) {
            if(csvColumnHeader == '')
	            csvColumnHeader = metadataType;
            else {
		        csvColumnHeader = csvColumnHeader + ',' + metadataType;
            }
        }
        csvColumnHeader = csvColumnHeader + '\n';
        System.debug('csvColumnHeader=' + csvColumnHeader);
        System.debug('maxListSize=' + maxListSize);

        for(integer index=0; index < maxListSize; index++ ) {
            String rowStr = ',';

			for(String metadataType : metadataTypes) {
				List<ToolingService.MetadataComponentDependency> resultList = metadataTypeMap.get(metadataType);

                if (!resultList.isEmpty()) {
                    if(index < resultList.size()) {
                        ToolingService.MetadataComponentDependency dependency = resultList.get(index);
                        rowStr += dependency.metadataComponentName + ',';
                    }
                    else{
                        rowStr += ',';
                    }
                }
                else {
                    rowStr += ',';
                }
        	}
            rowStr = rowStr.substring(1, rowStr.length()-1);
            csvRowValues.add(rowStr);
        }

        String documentName = 'MetadataDependencies-' + reportType + '-' + Datetime.now().format('MMM') + Datetime.now().year() + '.csv';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');

		// Insert the generated CSV file in Document object under "My Personal Documents".
        Document doc = new Document(
            Name = documentName,
            Body = Blob.valueOf(csvFile),
            AuthorId = UserInfo.getUserId(),
            FolderId = UserInfo.getUserId(),
            Type = 'csv',
            ContentType='application/vnd.ms-excel');
        insert doc;

        System.debug('doc.id=' + doc.id);
        System.debug('doc=' + doc);
        sendEmail(documentName, Blob.valueOf(csvFile), doc);
    }

    private static void sendEmail(String name, blob b, Document doc) {
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		// Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(name);
        efa.setBody(b);
        efa.setContentType(doc.ContentType);

        String[] toAddresses =  new String[]{UserInfo.getUserEmail()};

        // Sets the paramaters of the email
        email.setSubject('Metadata Dependency ' + name);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Please see attached Metadata Dependency!');

        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        // Sends the email
        Messaging.SendEmailResult [] r =
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

}