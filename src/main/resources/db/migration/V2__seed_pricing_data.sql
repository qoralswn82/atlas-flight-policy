-- ==========================================================================================
-- 운임 도메인 시드 데이터
-- Temporal 설계 검증: ICN→NRT 운임은 성수기 가격이 오른 2개 버전 포함
-- ==========================================================================================


-- ==========================================================================================
-- ATF_FARE_TAX — 세금/할증 마스터 (4종)
-- ==========================================================================================

-- ① 출국납부금 (KR) — 정액 10,000원, 기간 무제한
INSERT INTO ATF_FARE_TAX
    (FARE_TAX_ID, TAX_CD, TAX_NM, AMT_TYPE_CD, TAX_AMT, CRNCY_CD, TXBS_CD,
     VLD_BGNG_DT, VLD_END_DT, VSRN_ID, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FTAX001', 'KR', '출국납부금', 'FIXED', 10000.0000, 'KRW', 'BASE_FARE',
     '2026-01-01', '2099-12-31', 'e3b4c1a0-0001-4000-a000-000000000001',
     NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ② 유류할증료 (YQ) — 정률 15%, 기본 운임 기준, 비성수기
INSERT INTO ATF_FARE_TAX
    (FARE_TAX_ID, TAX_CD, TAX_NM, AMT_TYPE_CD, TAX_AMT, CRNCY_CD, TXBS_CD,
     VLD_BGNG_DT, VLD_END_DT, VSRN_ID, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FTAX002', 'YQ', '유류할증료', 'PCT', 0.1500, NULL, 'BASE_FARE',
     '2026-01-01', '2026-06-30', 'e3b4c1a0-0002-4000-a000-000000000002',
     NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ③ 유류할증료 (YQ) — 성수기 요율 인상 버전, 18% (Temporal 버전 추가 예시)
INSERT INTO ATF_FARE_TAX
    (FARE_TAX_ID, TAX_CD, TAX_NM, AMT_TYPE_CD, TAX_AMT, CRNCY_CD, TXBS_CD,
     VLD_BGNG_DT, VLD_END_DT, VSRN_ID, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FTAX003', 'YQ', '유류할증료(성수기)', 'PCT', 0.1800, NULL, 'BASE_FARE',
     '2026-07-01', '2099-12-31', 'e3b4c1a0-0003-4000-a000-000000000003',
     NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ④ 일본소비세 (JP_JCT) — 정률 10%, 누적 합계 기준, 일본 노선 전용
INSERT INTO ATF_FARE_TAX
    (FARE_TAX_ID, TAX_CD, TAX_NM, AMT_TYPE_CD, TAX_AMT, CRNCY_CD, TXBS_CD,
     VLD_BGNG_DT, VLD_END_DT, VSRN_ID, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FTAX004', 'JP_JCT', '일본소비세', 'PCT', 0.1000, NULL, 'TOTAL',
     '2026-01-01', '2099-12-31', 'e3b4c1a0-0004-4000-a000-000000000004',
     NOW(), 'sysadmin', NOW(), 'sysadmin');


-- ==========================================================================================
-- ATF_FARE — 운임 마스터 (5노선 7개 버전)
-- ==========================================================================================

-- ① KE ICN → NRT 비성수기 (2026-01-01 ~ 2026-06-30), 150,000원
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE001', 'YLOWKR', 'KE', 'ICN', 'NRT',
     150000.00, 'KRW', '2026-01-01', '2026-06-30', 'a1b2c3d4-0001-4000-b000-100000000001',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ② KE ICN → NRT 성수기 (2026-07-01 ~ 2026-12-31), 195,000원 — Temporal 버전 추가 예시
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE002', 'YHIGHKR', 'KE', 'ICN', 'NRT',
     195000.00, 'KRW', '2026-07-01', '2026-12-31', 'a1b2c3d4-0002-4000-b000-100000000002',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ③ OZ ICN → NRT 연중 (2026-01-01 ~ 2026-12-31), 145,000원
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE003', 'YLOWKR', 'OZ', 'ICN', 'NRT',
     145000.00, 'KRW', '2026-01-01', '2026-12-31', 'a1b2c3d4-0003-4000-b000-100000000003',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ④ KE ICN → LAX 연중, 520,000원
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE004', 'MLOWUS', 'KE', 'ICN', 'LAX',
     520000.00, 'KRW', '2026-01-01', '2026-12-31', 'a1b2c3d4-0004-4000-b000-100000000004',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ⑤ KE ICN → BKK 연중, 210,000원
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE005', 'MLOWTW', 'KE', 'ICN', 'BKK',
     210000.00, 'KRW', '2026-01-01', '2026-12-31', 'a1b2c3d4-0005-4000-b000-100000000005',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ⑥ OZ ICN → SIN 연중, 185,000원
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE006', 'MLOWSG', 'OZ', 'ICN', 'SIN',
     185000.00, 'KRW', '2026-01-01', '2026-12-31', 'a1b2c3d4-0006-4000-b000-100000000006',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');

-- ⑦ KE ICN → CDG (파리) 연중, 680,000원
INSERT INTO ATF_FARE
    (FARE_ID, FARE_CRTR_CD, ARLN_CD, DPTRE_ARPT_CD, ARVL_ARPT_CD,
     BASE_FARE_AMT, CRNCY_CD, VLD_BGNG_DT, VLD_END_DT, VSRN_ID,
     CBIN_CD, DEL_YN, REG_DT, RGTR_ID, MDFCN_DT, MDFR_ID)
VALUES
    ('FARE007', 'MLOWEU', 'KE', 'ICN', 'CDG',
     680000.00, 'KRW', '2026-01-01', '2026-12-31', 'a1b2c3d4-0007-4000-b000-100000000007',
     NULL, 'N', NOW(), 'sysadmin', NOW(), 'sysadmin');


-- ==========================================================================================
-- ATF_FARE_TAX_MAPNG — 운임-세금 매핑 (17건)
-- 일본 노선(NRT): 출국납부금(1) → 유류할증(2) → 일본소비세(3, TOTAL기준)
-- 기타 노선:      출국납부금(1) → 유류할증(2)
-- ==========================================================================================

-- FARE001: KE ICN→NRT 비성수기 (YQ=FTAX002, 15%)
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG001', 'FARE001', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG002', 'FARE001', 'FTAX002', 2, NOW(), 'sysadmin'),  -- 유류할증 15%
       ('MAPNG003', 'FARE001', 'FTAX004', 3, NOW(), 'sysadmin');  -- 일본소비세 10%(TOTAL)

-- FARE002: KE ICN→NRT 성수기 (YQ=FTAX003, 18%)
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG004', 'FARE002', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG005', 'FARE002', 'FTAX003', 2, NOW(), 'sysadmin'),  -- 유류할증 18%(성수기)
       ('MAPNG006', 'FARE002', 'FTAX004', 3, NOW(), 'sysadmin');  -- 일본소비세 10%(TOTAL)

-- FARE003: OZ ICN→NRT (YQ=FTAX002, 15%)
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG007', 'FARE003', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG008', 'FARE003', 'FTAX002', 2, NOW(), 'sysadmin'),  -- 유류할증 15%
       ('MAPNG009', 'FARE003', 'FTAX004', 3, NOW(), 'sysadmin');  -- 일본소비세 10%(TOTAL)

-- FARE004: KE ICN→LAX (일본소비세 없음)
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG010', 'FARE004', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG011', 'FARE004', 'FTAX002', 2, NOW(), 'sysadmin');  -- 유류할증 15%

-- FARE005: KE ICN→BKK
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG012', 'FARE005', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG013', 'FARE005', 'FTAX002', 2, NOW(), 'sysadmin');  -- 유류할증 15%

-- FARE006: OZ ICN→SIN
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG014', 'FARE006', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG015', 'FARE006', 'FTAX002', 2, NOW(), 'sysadmin');  -- 유류할증 15%

-- FARE007: KE ICN→CDG (파리)
INSERT INTO ATF_FARE_TAX_MAPNG (FARE_TAX_MAPNG_ID, FARE_ID, FARE_TAX_ID, APLCN_ORD, REG_DT, RGTR_ID)
VALUES ('MAPNG016', 'FARE007', 'FTAX001', 1, NOW(), 'sysadmin'),  -- 출국납부금
       ('MAPNG017', 'FARE007', 'FTAX002', 2, NOW(), 'sysadmin');  -- 유류할증 15%
