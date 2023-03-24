package yeonjeans.saera.util;

import java.util.ArrayList;

public class Parsing {

    public static ArrayList<Integer> stringToIntegerArray(String str){
        ArrayList<Integer> list = new ArrayList<>();
        String sub = str.substring(1, str.length()-1);
        String[] array = sub.split(",");
        for(String x : array){
            list.add(Integer.valueOf(x.trim()));
        }
        return list;
    }

    public static ArrayList<Double> stringToDoubleArray(String str){
        ArrayList<Double> list = new ArrayList<>();
        String sub = str.substring(1, str.length()-1);
        String[] array = sub.split(",");
        for(String x : array){
            list.add(Double.valueOf(x.trim()));
        }
        return list;
    }
}
