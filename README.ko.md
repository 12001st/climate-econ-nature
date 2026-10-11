# The Economic Nature of Climate Shocks

[English](README.md) | **한국어**

ASEAN+3 경제의 기후 리스크에 관한 2023년 연구보고서 중 제3장 "기후 충격의 경제적 성격(The Economic Nature of Climate Shocks)"의 MATLAB 코드입니다.

## 연구 질문

극단적 기상이 경제를 덮칠 때, 그것은 **공급 충격**(산출 감소, 물가 상승)처럼 작용할까, **수요 충격**(산출과 물가가 같은 방향)처럼 작용할까, 아니면 둘 다일까? 이 답은 통화정책에 중요합니다. 중앙은행은 순수한 공급 충격은 넘겨 볼 수 있지만 수요 충격에는 대응해야 하기 때문입니다.

대상은 14개 경제입니다: 브루나이, 캄보디아, 인도네시아, 라오스, 말레이시아, 미얀마, 필리핀, 싱가포르, 태국, 베트남, 중국, 일본, 한국, 홍콩.

## 방법

1. **거시 충격 식별.** 경제별로 분기 소규모 개방경제 VAR을 추정합니다(1981Q1–2022Q4).
   - 내생변수: 실질 GDP 성장률, CPI 인플레이션, 예금금리
   - 외생변수: 미국 실질 GDP 성장률, 세계 원자재가격 상승률
   - 시차 2, 상수항과 추세

   총공급·총수요·통화정책 충격을 2분기 동안 유지되는 부호제약으로 식별합니다.

   | 충격 | GDP 성장률 | 인플레이션 | 금리 |
   |---|---|---|---|
   | 공급 | + | − | 제약 없음 |
   | 수요 | + | + | + |
   | 통화 | + | + | − |

2. **기후와 연결.** 식별된 공급·수요 충격을 기후 극한 지수(AECI)와 그 구성요소(폭염, 한파, 가뭄, 강수, 바람)에 회귀합니다. 패널 회귀와 국가별 회귀를 모두 수행합니다.

이 레포에는 1단계와 이를 보조하는 월별·연별 분석이 들어 있습니다. 기후 지수 작성과 2단계 회귀는 포함되어 있지 않습니다.

## 폴더 구성

```
code/
  load_Quarterly.m            분기 패널 자료 로드 및 변환
  run_VAR_Quarterly_Sign.m    주 모형: 경제별 부호제약 VARX, 충격 저장
  load_Monthly.m              월별 패널 자료 로드 및 변환
  run_VAR_Monthly_Sign.m      주 모형의 월별 버전
  run_VAR_Monthly_Choleski.m  기후 지수를 맨 앞에 둔 월별 VAR (축차적 식별)
  plot_Monthly.m              경제별 월별 경제·기후 시계열 그림
  load_Yearly.m, plot_Yearly.m  연별 기후 지수 그림
data/                         입력 엑셀 파일 위치 (배포하지 않음)
output/                       그림과 충격 시계열 출력 위치
```

## 필요 환경

- MATLAB R2021a 이상. `plot_Monthly.m`은 Econometrics Toolbox(`crosscorr`)도 필요합니다.
- Ambrogio Cesa-Bianchi의 [VAR Toolbox](https://github.com/ambropo/VAR-Toolbox)를 MATLAB 경로에 추가 (`VARmodel`, `SR`, `VARir`, `VARirband`, `SaveFigure` 등).

## 데이터

입력 자료는 배포하지 않습니다. 각국 거시 시계열과 기후 지수를 결합한 자료입니다. 코드를 실행하려면 다음 파일을 `data/`에 두세요(시트 이름 `data`, 위 순서대로 국가를 세로로 쌓은 형태).

| 파일 | 빈도 | 사용하는 스크립트 |
|---|---|---|
| `data_Quarterly_1981_2022_final.xlsx` | 분기, 1981Q1–2022Q4 | `load_Quarterly.m` |
| `data_Monthly_1981_2022_final.xlsx` | 월, 1981M1–2022M12 | `load_Monthly.m` |
| `Yearly_1981_2019_final.xlsx` | 연, 1981–2019 | `load_Yearly.m` |

필요한 변수 이름은 각 `load_*.m` 파일 상단에 적혀 있습니다.

## 실행

레포 최상위 폴더에서 실행합니다.

```matlab
addpath code
run_VAR_Quarterly_Sign      % 주 모형, 자료를 스스로 불러옴

load_Monthly                % 월별 스크립트는 자료가 작업공간에 있어야 함
run_VAR_Monthly_Sign
run_VAR_Monthly_Choleski
```

주 모형은 충격반응 그림을 `output/Quarterly/figures_det2/`에, 모든 경제의 식별된 충격을 `output/Quarterly/eps_sign_3x3_L2_LX2_det2_Q.xlsx`(열: 날짜, 국가 id, 공급, 수요, 통화)에 저장합니다.
