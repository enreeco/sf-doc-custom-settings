public class ConfigurationManager{
    
    //global endpoint
    public static String CALLOUT_ENDPOINT{
        get{
            //return 'http://quotesondesign.com/wp-json/posts?filter[orderby]=rand';
            return Endpoints__c.getOrgDefaults().Callout_Endpoint__c;
        }
    }

    //global timeout in ms
    public static Integer CALLOUT_TIMEOUT{
        get{
            //return 60000;
            return Endpoints__c.getOrgDefaults().Callout_Timeout__c.intValue();
        }
    }

    //user/profile centric debug mode
    public static Boolean DEBUG_MODE{
        get{
            //return true;
            return Debugging__c.getInstance().Callout_Debug_Mode__c;
        }
    }

    //returns a specific date format given the locale code
    public static String getDateFormat(String localeCode){
    	
        //if(localeCode == 'it_IT'){
        //    return 'dd/MM/yyyy';
        //}
        //return 'MM/dd/yyyy';*/
    	Date_Formats__c defaultFormat = Date_Formats__c.getInstance('Default');
    	Date_Formats__c localeFormat = Date_Formats__c.getInstance(localeCode);
        if(localeFormat != null) return localeFormat.Format__c;
        return defaultFormat.Format__c;
    }

}