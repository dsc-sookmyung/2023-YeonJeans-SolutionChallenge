package yeonjeans.saera.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import yeonjeans.saera.Service.CustomServiceImpl;
import yeonjeans.saera.dto.*;
import yeonjeans.saera.exception.ErrorResponse;
import yeonjeans.saera.security.dto.AuthMember;

import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
@RestController
public class CustomController {
    private final CustomServiceImpl customService;

    @Operation(summary = "사용자 정의 문장 생성", description = "문장 내용(content), tag들을 이용해 사용자 정의 문장을 생성합니다.", tags = { "Custom Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "요청 성공", content = @Content(schema = @Schema(implementation = CustomResponseDto.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @PostMapping("/customs")
    public ResponseEntity<?> createCustom(
            @RequestBody(required = true)CustomRequestDto requestDto,
            @RequestHeader String Authorization
    ){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        CustomResponseDto dto =  customService.create(requestDto.getContent(), requestDto.getTags(), principal.getId());
        return ResponseEntity.ok().body(dto);
    }

    @Operation(summary = "사용자 정의 문장 리스트 조회", description = "문장 내용(content)나 tag이름을 이용하여 사용자 정의 문장 리스트를 검색합니다.", tags = { "Custom Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = { @Content(array = @ArraySchema(schema = @Schema(implementation = ListItemDto.class)))}),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @GetMapping("/customs")
    public ResponseEntity<?> returnCustomList(
            @RequestParam(value = "bookmarked", defaultValue = "false") boolean bookmarked,
            @RequestParam(value = "content", required = false) String content,
            @RequestParam(value = "tags", required= false) ArrayList<String> tags,
            @RequestHeader String Authorization
    ){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        List<ListItemDto> list;
        list = customService.getCustoms(bookmarked, content, tags, principal.getId());

        return ResponseEntity.ok().body(list);
    }

    @Operation(summary = "사용자 정의 문장 조회", description = "문장 내용(content), tag들을 이용해 사용자 정의 문장을 생성합니다.", tags = { "Custom Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = @Content(schema = @Schema(implementation = CustomResponseDto.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @GetMapping("/customs/{id}")
    public ResponseEntity<?> returnCustom(
            @PathVariable(required = true) Long id,
            @RequestHeader String Authorization
    ){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        CustomResponseDto dto =  customService.read(id, principal.getId());
        return ResponseEntity.ok().body(dto);
    }

    @Operation(summary = "사용자 정의 문장 삭제", description = "id(fk)를 이용해 사용자 정의 문장을 삭제합니다.", tags = { "Custom Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "성공" ),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @DeleteMapping("/customs/{id}")
    public ResponseEntity<?> deleteCustom(
            @PathVariable(required = true) Long id,
            @RequestHeader String Authorization
    ){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        customService.delete(id, principal.getId());

        return ResponseEntity.ok().build();
    }

    @Operation(summary = "사용자 정의 태그 조회", description = "사용자가 정의한 문장의 태그 목록을 조회합니다.", tags = { "Custom Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "성공" , content = { @Content(array = @ArraySchema(schema = @Schema(implementation = NameIdDto.class)))}),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @GetMapping("/customs/tags")
    ResponseEntity<?> returnCustomList(
            @RequestHeader String Authorization
    ) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        List<NameIdDto> list = customService.getTagList(principal.getId());
        return ResponseEntity.ok().body(list);
    }

    @Operation(summary = "사용자 정의 문장 예시 음성 조회", description = "custom id를 이용하여 예시 음성을 조회 합니다.", tags = { "Custom Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공"),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            })
    @GetMapping("/customs/record/{id}")
    public ResponseEntity<?> returnExampleRecord(@PathVariable Long id){
        Resource resource = customService.getExampleRecord(id);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("audio", "wav"));

        return ResponseEntity.ok().headers(headers).body(resource);
    }
}