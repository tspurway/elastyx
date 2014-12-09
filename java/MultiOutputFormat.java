package elastyxOutput;

import org.apache.hadoop.mapred.lib.MultipleTextOutputFormat;
import org.apache.hadoop.io.Text;

import org.json.JSONObject;

public class MultiOutputFormat
    extends MultipleTextOutputFormat<Text, Text> {

    @Override
    protected String generateFileNameForKeyValue(Text key, Text value, String name) {
        JSONObject json = new JSONObject(key.toString());
        if (json.optInt("newtabs", -1) == -1) {
            return "impression_stats/" + json.getString("date") + "/" + name + ".json";
        } else {
            return "newtab_stats/" + json.getString("date") + "/" + name + ".json";
        }
    }
}

