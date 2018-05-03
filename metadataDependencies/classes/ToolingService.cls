
// From Open source
public with sharing class ToolingService {

	public enum SObjectType {
        ApexClass,
		CustomObject,
        MetadataComponentDependency
    }

    // The API version used relates to the types and structures defined here
    private static final String TOOLING_API_URI = '/services/data/v43.0/tooling';

    // Session Id can be resolved automatically depending on constructor used
    private String sessionId;

    // Interface used to implement custom serialization on SObject based types
    private interface ISerialize {
        void serialize(JSONGenerator generator);
    }

    /**
     * Uses the current users Session Id, only compatible in a interactive context
     **/
    public ToolingService() {
        this.sessionId = UserInfo.getSessionId();
        if(this.sessionId==null)
            throw new APIException('Unable to obtain Session Id');
    }

    /**
     * Uses the given Session Id, useful when using the API in a batch context
     **/
    public ToolingService(String sessionId) {
        this.sessionId = sessionId;
    }

    /**
     * Using this query as an example for calling the private static helper method.
     * query
     * @description Uses the queryString to issue a query via the tooling API
     * @param The query string to use
     * @return Query Result
     * @throws Exception if an an exception was encountered.
     */
    public QueryResult query(String queryString) {
        HttpResponse response = submitRestCall('/query/?q=' + EncodingUtil.urlEncode(queryString, 'UTF-8'));
        String res = response.getBody();
        System.debug('response=' + res);
        return parseQueryResult(res);
    }

	public QueryResult dependencyCall(String id){
        HttpResponse response = submitRestCall('/sobjects/MetadataComponentDependency/' + id);
        String res = response.getBody();
        System.debug('response=' + res);
        return parseQueryResult(res);
    }

    //Public Inner Classes for Handling API Requests

    public class QueryResult {
        public boolean              done;
        public String               entityTypeName;
        //public String               nextRecordsUrl;
        public SObject_x[]          records;
        public Integer              size;
        public Integer              totalSize;
        public String               queryLocator;
    }

    public class MetadataComponentDependency extends SObject_x implements ISerialize {
        public String              	metadataComponentId;
        public String              	metadataComponentNamespace;
        public String              	metadataComponentName;
        public String               metadataComponentType;
        public String               refMetadataComponentId ;
        public String               refMetadataComponentName;
        public String          		refMetadataComponentType;
        public String          		refMetadataComponentNamespace;

		public MetadataComponentDependency() {

            super(SObjectType.CustomObject);
            //super(SObjectType.MetadataComponentDependency);
        }
        public override void serialize(JSONGenerator jsonGen) {
            super.serialize(jsonGen);
            if(metadataComponentId!=null)
                jsonGen.writeStringField('metadataComponentId', metadataComponentId);
            if(metadataComponentNamespace!=null)
                jsonGen.writeStringField('metadataComponentNamespace', metadataComponentNamespace);


            if(metadataComponentName!=null)
                jsonGen.writeStringField('metadataComponentName', metadataComponentName);
            if(metadataComponentType!=null)
                jsonGen.writeStringField('metadataComponentType', metadataComponentType);
            if(refMetadataComponentId!=null)
                jsonGen.writeStringField('refMetadataComponentId', refMetadataComponentId);
            if(refMetadataComponentNamespace!=null)
                jsonGen.writeStringField('refMetadataComponentNamespace', refMetadataComponentNamespace);
            if(refMetadataComponentName!=null)
                jsonGen.writeStringField('refMetadataComponentName', refMetadataComponentName);
            if(refMetadataComponentType!=null)
                jsonGen.writeStringField('refMetadataComponentType', refMetadataComponentType);
        }
    }

    public class Error {
        public String[] fields;
        public String   message;
        public String   statusCode;
    }

    public class ErrorResponse{
        public List<String> fields;
        public String errorCode;
        public String message;
    }

    public virtual class SObject_x {
        public transient SObjectType type_x {get; private set;}
        public transient String[]    fieldsToNull;
        public Id                    id;
        public Id                    createdById;
        //public User_x                createdBy;
        public DateTime              createdDate;
        public boolean               isDeleted;
        public Id                    lastModifiedById;
       // public User_x                lastModifiedBy;
        public Datetime              lastModifiedDate;
        public DateTime              systemModstamp;
        public SObject_x(SObjectType sObjectType){
            type_x = sObjectType;
        }
        public virtual void serialize(JSONGenerator jsonGen) {
            if(id!=null)
                jsonGen.writeStringField('id', id);
            if(fieldsToNull!=null)
                for(String fieldToNull : fieldsToNull)
                    jsonGen.writeNullField(fieldToNull);
        }
    }


    //Private helper methods go here
    //

    /*
     * Static helper method for the "happy path" of JSON deserialization.
     * This method should be used for the public methods when the generic JSON deserialize method
     * may be used. Sends a HTTP GET request.
     */
    private Object submitRestCallAndDeserialize(String relativeUrl,Type classType){
        return submitRestCallAndDeserialize(relativeUrl, classType, 'GET');
    }

    /*
     * Static helper method for the "happy path" of JSON deserialization.
     * This method should be used for the public methods when the generic JSON deserialize method
     * may be used. Sends a HTTP requested based on method parameter.
     */
    private Object submitRestCallAndDeserialize(String relativeUrl,Type classType, String method){
        return submitRestCallAndDeserialize(relativeUrl, classType, method, null);
    }

    /*
     * Static helper method for the "happy path" of JSON deserialization.
     * This method should be used for the public methods when the generic JSON deserialize method
     * may be used. Sends a HTTP requested based on method parameter and data.
     */
    private Object submitRestCallAndDeserialize(String relativeUrl,Type classType, String method, Object data){
        HttpResponse response = submitRestCall(relativeUrl, method, data);
        String responseBody = response.getBody();
        if(responseBody!=null && responseBody.length()>0)
            return JSON.deserialize(responseBody,classType);
        return null;
    }

    /*
     * Helper method for submitting the REST HTTP GET request.
     *
     * @throws ToolingAPIAuthorizationException if the remote site is not authorized.
     */
    private HttpResponse submitRestCall(String relativeUrl){
        return submitRestCall(relativeUrl, 'GET');
    }
    /*
     * Helper method for submitting the REST request using the given method.
     *
     * @throws ToolingAPIAuthorizationException if the remote site is not authorized.
     */
    private HttpResponse submitRestCall(String relativeUrl, String method){
        return submitRestCall(relativeUrl, method, null);
    }

    /*
     * Helper method for submitting the REST request using the given method and data.
     *
     * @throws ToolingAPIAuthorizationException if the remote site is not authorized.
     */
    private HttpResponse submitRestCall(String relativeUrl, String method, Object data){
        Http h = new Http();
        HttpRequest queryReq = new HttpRequest();
        queryReq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + TOOLING_API_URI + relativeUrl);
        queryReq.setHeader('Authorization', 'OAuth ' + this.sessionId);
        queryReq.setHeader('Content-Type', 'application/json');
        queryReq.setMethod(method);
        queryReq.setTimeout(120000);
        if(data!=null)
        {
            // Custom serializer?
            if(data instanceof ISerialize)
            {
                ISerialize dataToserialize = (ISerialize) data;
                JSONGenerator jsonGen = JSON.createGenerator(false);
                jsonGen.writeStartObject();
                dataToserialize.serialize(jsonGen);
                jsonGen.writeEndObject();
                queryReq.setBody(jsonGen.getAsString());
            }
            else
            {
                // Standard JSON serializer emits null values,
                //    which are generally not tolerated by Tooling API
                queryReq.setBody(JSON.serialize(data));
            }
        }

        HttpResponse queryRes = null;
        try
        {
            queryRes = h.send(queryReq);
        }
        catch (System.CalloutException ce)
        {
            if (ce.getMessage().containsIgnoreCase('unauthorized endpoint'))
            {
                throw new APIAuthorizationException(ce);
            }
            else
            {
                throw ce;
            }
        }

        Integer successCode = 200;
        if(method.equals('POST'))
            successCode = 201;
        else if(method.equals('DELETE'))
            successCode = 204;
        if(queryRes.getStatusCode() != successCode)
            if(queryRes.getBody().length()>0)
                throw new APIException((List<ErrorResponse>) JSON.deserialize(queryRes.getBody(), List<ErrorResponse>.class));
            else
                throw new APIException('Unexpected HTTP Status ' + queryRes.getStatusCode());
        return queryRes;
    }

    /**
     * Helper method for parsing query results
     **/
    private QueryResult parseQueryResult(String jsonStr){
        QueryResult queryResult = (QueryResult)JSON.deserialize(jsonStr, ToolingService.QueryResult.class);
        queryResult.records = getQueryResultRecords(jsonStr);
        return queryResult;
    }

    /**
     * Helper method for parsing the QueryResult response and determining
     * which instance of sObject_x to use
     */
    private List<SObject_x> getQueryResultRecords(String jsonStr){

        String recordType = getRecordType(jsonStr);

        if(recordType != null){
            JSONParser parser = JSON.createParser(jsonStr);

            while (parser.nextToken() != null) {
                if ((parser.getText() == 'records')) {
                    parser.nextToken();
                    return (List<SObject_x>)parser.readValueAs(Type.forName('List<ToolingService.'+recordType+'>'));
                }
            }
        }

        return null;
    }

    /**
     * Helper method for parsing type attribute from query result records in JSON response
     */
    private String getRecordType(String jsonStr){
        JSONParser parser = JSON.createParser(jsonStr);

        while (parser.nextToken() != null) {
            if ((parser.getText() == 'records')) {
                while(parser.nextToken() != null) {
                    if(parser.getText() == 'attributes'){
                        while(parser.nextToken() != null){
                            if(parser.getText() == 'type'){
                                //Value of type attribute
                                parser.nextToken();
                                return parser.getText();
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

	public class APIException extends Exception{
        public APIException(List<ErrorResponse> errorResponses){
            this(errorResponses[0].errorCode + ' : ' + errorResponses[0].message);
        }
    }

    public class APIAuthorizationException extends Exception
    {

    }
}