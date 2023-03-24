package yeonjeans.saera.controller;

import io.swagger.v3.oas.annotations.Operation;
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
import yeonjeans.saera.Service.PracticeServiceImpl;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.dto.PracticeRequestDto;
import yeonjeans.saera.dto.PracticeResponseDto;
import yeonjeans.saera.exception.ErrorResponse;
import yeonjeans.saera.security.dto.AuthMember;

@RequiredArgsConstructor
@RestController
public class PracticeController {
    private final PracticeServiceImpl practicedService;

    @Operation(summary = "유저 음성 파일 조회", description = "type과 id를 사용하여 유저의 음성 녹음 파일을 제공합니다.", tags = { "Practiced Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공"),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @GetMapping("/practice/record")
    public ResponseEntity returnPracticedRecord(@RequestParam(value = "type", required = true) ReferenceType type,
                                                @RequestParam(value = "fk", required = true) Long fk,
                                                @RequestHeader String Authorization) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        Resource resource = practicedService.getRecord(type, fk, principal.getId());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("audio", "wav"));
        return ResponseEntity.ok().headers(headers).body(resource);
    }

    @Operation(summary = "학습 정보 조회", description = "type과 id를 사용하여 학습정보를 제공합니다..", tags = { "Practiced Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = @Content(schema = @Schema(implementation = PracticeResponseDto.class))),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @GetMapping("/practice")
    public ResponseEntity<?> returnPracticed(@RequestParam(value = "type", required = true) ReferenceType type,
                                             @RequestParam(value = "fk", required = true) Long fk,
                                             @RequestHeader String Authorization) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        PracticeResponseDto dto = practicedService.read(type, fk, principal.getId());

        return ResponseEntity.ok().body(dto);
    }

    @Operation(summary = "학습 정보 생성", description = "type과 id를 사용하여 학습 정보를 생성합니다.", tags = { "Practiced Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = @Content(schema = @Schema(implementation = PracticeResponseDto.class))),
                    @ApiResponse(responseCode = "422", description = "음성 파일 오류", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            })
    @PostMapping(value = "/practice", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createPracticed(@ModelAttribute PracticeRequestDto requestDto, @RequestHeader String Authorization) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        Practice practice = practicedService.create(requestDto, principal.getId());
        return ResponseEntity.ok().body(new PracticeResponseDto(practice));
    }
}