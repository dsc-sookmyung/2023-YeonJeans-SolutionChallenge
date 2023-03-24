package yeonjeans.saera.util;

import org.springframework.web.multipart.MultipartFile;
import yeonjeans.saera.exception.CustomException;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

import static yeonjeans.saera.exception.ErrorCode.UPLOAD_FAILURE;

public class File {
    private static final String uploadPath = Paths.get(System.getProperty("user.home")).resolve("upload").toString();

    public static String makeFolder(){
        String str = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String folderPath = str.replace("\\", java.io.File.separator);

        java.io.File uploadPathFolder = new java.io.File(uploadPath, folderPath);

        if(!uploadPathFolder.exists()){
            uploadPathFolder.mkdirs();
        }
        return folderPath;
    }

    public static String saveFile(MultipartFile file){
        String originalName = file.getOriginalFilename();
        String fileName = originalName.substring(originalName.lastIndexOf("\\")+1);

        String folderPath = makeFolder();
        String uuid = UUID.randomUUID().toString();

        String saveName = uploadPath + java.io.File.separator + folderPath + java.io.File.separator + uuid + "_" +fileName;
        Path savePath = Paths.get(saveName);

        try{
            file.transferTo(savePath);
        }catch (IOException e){
            throw new CustomException(UPLOAD_FAILURE);
        }
        return saveName;
    }
}
