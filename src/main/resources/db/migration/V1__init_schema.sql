-- ==========================================================================================
-- 운임 도메인 스키마
-- Temporal 설계: UPDATE 금지 — 운임·세율 변경은 항상 새 버전 INSERT
-- ==========================================================================================


-- ==========================================================================================
-- 운임 테이블 (ATF_FARE)
-- ARLN_CD + O&D + 유효 기간 조합으로 하나의 버전 운임을 식별
-- 운임 변경 시 기존 행 DEL_YN='Y' + 새 행 INSERT (금액 UPDATE 금지)
-- ==========================================================================================

CREATE TABLE ATF_FARE
(
    FARE_ID       VARCHAR(30)   NOT NULL COMMENT '운임_식별자'                                                                                        PRIMARY KEY,
    FARE_CRTR_CD  VARCHAR(14)   NOT NULL COMMENT '운임_기준_코드(Fare Basis Code) — ATPCO 표준 식별자(예:YOWKR,MLE7AP). V1 에서는 검색 필터로 사용하지 않지만 V2 RBD/Cabin 매핑을 위해 반드시 저장',
    ARLN_CD       VARCHAR(3)    NOT NULL COMMENT '항공사_코드 — IATA 2자리 코드(예:KE=대한항공, OZ=아시아나)',
    DPTRE_ARPT_CD VARCHAR(3)    NOT NULL COMMENT '출발_공항_코드 — IATA 3자리 공항 코드(예:ICN=인천, GMP=김포)',
    ARVL_ARPT_CD  VARCHAR(3)    NOT NULL COMMENT '도착_공항_코드 — IATA 3자리 공항 코드(예:NRT=나리타, LAX=로스앤젤레스)',
    BASE_FARE_AMT DECIMAL(15,2) NOT NULL COMMENT '기본_운임_금액 — 세금·할증 완전 제외 순수 운임. 고객 총 결제액 = 이 값 + ATF_FARE_TAX 합계',
    CRNCY_CD      VARCHAR(3)    NOT NULL COMMENT '통화_코드 — ISO 4217 3자리(예:KRW=원화, USD=달러, JPY=엔화)',
    VLD_BGNG_DT   DATE          NOT NULL COMMENT '유효_시작_일자 — 이 운임으로 발권 가능한 첫 날(판매 개시일). 탑승일 기준이 아닌 발권일 기준',
    VLD_END_DT    DATE          NOT NULL COMMENT '유효_종료_일자 — 이 운임으로 발권 가능한 마지막 날(판매 종료일). VLD_BGNG_DT 이상이어야 함',
    VSRN_ID       VARCHAR(36)   NOT NULL COMMENT '버전_식별자 — UUID. Offer 계산 시 이 값을 PRICING_TRACE JSON 에 기록. 나중에 어떤 운임 행을 사용했는지 이 키로 정확히 재현 가능',
    CBIN_CD       VARCHAR(5)    NULL     COMMENT '객실_등급_코드 — V1=NULL(단일 등급 미분리). V2 에서 Y(이코노미)/C(비즈니스)/F(일등석) 값으로 등급별 운임 분리. NULL 일 때 조회 시 모든 등급에 해당하는 운임으로 취급',
    DEL_YN        VARCHAR(1)    DEFAULT 'N' NOT NULL COMMENT '삭제_여부 — N:정상, Y:삭제. 논리 삭제만 허용(물리 DELETE 금지). UPDATE 도 DEL_YN 변경 외에는 금지',
    REG_DT        DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록_일시',
    RGTR_ID       VARCHAR(30)   NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT      DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '수정_일시 — 실질적으로 DEL_YN 변경 시만 발생. 운임 금액 변경은 새 행 INSERT 만',
    MDFR_ID       VARCHAR(30)   NOT NULL COMMENT '수정자_아이디'
) COMMENT '운임 — Temporal: UPDATE 금지, 변경은 새 버전 INSERT 만' COLLATE = UTF8MB4_UNICODE_CI;

-- 운임 조회 핵심 인덱스: O&D + 유효 기간 범위 검색
CREATE INDEX IDX_FARE_LOOKUP ON ATF_FARE (ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD, VLD_BGNG_DT, VLD_END_DT);


-- ==========================================================================================
-- 세금/할증 테이블 (ATF_FARE_TAX)
-- 정액(FIXED)과 정률(PCT) 두 유형을 단일 테이블로 관리
-- AMT_TYPE_CD=FIXED: TAX_AMT 는 통화 금액, CRNCY_CD 필수
-- AMT_TYPE_CD=PCT:   TAX_AMT 는 소수 비율(예:0.1500=15%), CRNCY_CD 는 NULL
-- ==========================================================================================

CREATE TABLE ATF_FARE_TAX
(
    FARE_TAX_ID   VARCHAR(30)   NOT NULL COMMENT '세금_할증_식별자'                                                                                   PRIMARY KEY,
    TAX_CD        VARCHAR(10)   NOT NULL COMMENT '세금_코드 — 업계 표준 코드(예:KR=출국세, YQ=유류할증료, JP_JCT=일본소비세). 동일 코드로 기간이 다른 여러 버전 존재 가능',
    TAX_NM        VARCHAR(100)  NOT NULL COMMENT '세금_명 — 화면·영수증 표시용 한국어 명칭(예:출국납부금, 유류할증료)',
    AMT_TYPE_CD   VARCHAR(10)   NOT NULL COMMENT '금액_유형_코드 — FIXED(정액)/PCT(정률). 이 값에 따라 TAX_AMT 의 해석 방식이 완전히 달라짐',
    TAX_AMT       DECIMAL(15,4) NOT NULL COMMENT '세금_금액 — AMT_TYPE_CD=FIXED 이면 절대 금액(예:10000.0000원), PCT 이면 소수 비율(예:0.1500=15%). DECIMAL(15,4)로 정률 정밀도 확보',
    CRNCY_CD      VARCHAR(3)    NULL     COMMENT '통화_코드 — FIXED 유형일 때만 필수(예:KRW). PCT 유형이면 NULL(비율이므로 통화 무관)',
    TXBS_CD       VARCHAR(20)   DEFAULT 'BASE_FARE' NOT NULL COMMENT '과세_기준_코드 — PCT 유형의 곱셈 기준값 결정. BASE_FARE=기본운임만, TOTAL=직전 단계까지의 누적 합계. ATF_FARE_TAX_MAPNG.APLCN_ORD 순서와 반드시 함께 해석해야 함',
    VLD_BGNG_DT   DATE          NOT NULL COMMENT '유효_시작_일자 — 이 세금이 적용되는 첫 날. 세율 변경 시 새 행 INSERT',
    VLD_END_DT    DATE          NOT NULL COMMENT '유효_종료_일자 — 이 세금이 적용되는 마지막 날',
    VSRN_ID       VARCHAR(36)   NOT NULL COMMENT '버전_식별자 — UUID. ATF_FARE 와 동일한 재현성 추적 방식',
    REG_DT        DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록_일시',
    RGTR_ID       VARCHAR(30)   NOT NULL COMMENT '등록자_아이디',
    MDFCN_DT      DATETIME      DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '수정_일시',
    MDFR_ID       VARCHAR(30)   NOT NULL COMMENT '수정자_아이디'
) COMMENT '세금_할증 — Temporal: 세율 변경도 새 버전 INSERT 만' COLLATE = UTF8MB4_UNICODE_CI;

CREATE INDEX IDX_FARE_TAX_CD ON ATF_FARE_TAX (TAX_CD, VLD_BGNG_DT, VLD_END_DT);


-- ==========================================================================================
-- 운임-세금 매핑 테이블 (ATF_FARE_TAX_MAPNG)
-- 운임:세금 N:M 연결 + APLCN_ORD 로 계산 순서 제어
-- APLCN_ORD 가 낮은 번호부터 계산. PCT+TXBS_CD='TOTAL' 은 앞 순서 세금까지 누적한 값에 곱함
-- ==========================================================================================

CREATE TABLE ATF_FARE_TAX_MAPNG
(
    FARE_TAX_MAPNG_ID VARCHAR(30) NOT NULL COMMENT '운임_세금_매핑_식별자'                                                                             PRIMARY KEY,
    FARE_ID           VARCHAR(30) NOT NULL COMMENT '운임_식별자 — ATF_FARE.FARE_ID 참조. 해당 운임에 이 세금을 적용',
    FARE_TAX_ID       VARCHAR(30) NOT NULL COMMENT '세금_할증_식별자 — ATF_FARE_TAX.FARE_TAX_ID 참조',
    APLCN_ORD         TINYINT     DEFAULT 1 NOT NULL COMMENT '적용_순서 — 낮은 숫자부터 계산(1=첫 번째). PCT+TXBS_CD=TOTAL 조합일 때 이 순서가 금액에 직접 영향을 줌. 정액세(FIXED)는 순서 무관하므로 앞 번호에 배치 권장',
    REG_DT            DATETIME    DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '등록_일시',
    RGTR_ID           VARCHAR(30) NOT NULL COMMENT '등록자_아이디'
) COMMENT '운임_세금_매핑 — 운임:세금 N:M 연결 및 적용 순서 관리' COLLATE = UTF8MB4_UNICODE_CI;

ALTER TABLE ATF_FARE_TAX_MAPNG
    ADD CONSTRAINT FK_FARE_TAX_MAPNG_FARE
        FOREIGN KEY (FARE_ID) REFERENCES ATF_FARE (FARE_ID);

ALTER TABLE ATF_FARE_TAX_MAPNG
    ADD CONSTRAINT FK_FARE_TAX_MAPNG_TAX
        FOREIGN KEY (FARE_TAX_ID) REFERENCES ATF_FARE_TAX (FARE_TAX_ID);

-- 동일 운임에 동일 세금 중복 방지
CREATE UNIQUE INDEX UK_FARE_TAX_MAPNG ON ATF_FARE_TAX_MAPNG (FARE_ID, FARE_TAX_ID);
