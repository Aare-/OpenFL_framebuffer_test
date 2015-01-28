package com.subfty.sub.nat;

import java.io.*;
//import android.util.Log;

class Nat{

	public static String getConfig(String def){
		try {
			File config = new File("/sdcard/zombiebucket_config.xml");
			if(config.exists()){
				FileInputStream fIn = new FileInputStream(config);
				BufferedReader myReader = new BufferedReader(new InputStreamReader(fIn));
				String aDataRow = "";
				String aBuffer = "";
				while ((aDataRow = myReader.readLine()) != null) 
					aBuffer += aDataRow;
				
				def = aBuffer;
				myReader.close();
			}else{
				config.createNewFile();
				FileOutputStream fOut = new FileOutputStream(config);
				OutputStreamWriter myOutWriter = new OutputStreamWriter(fOut);

				myOutWriter.append(def);

				myOutWriter.close();
				fOut.close();
			}
			
		} catch (Exception e) {}

		return def;
	}

}