FIELDS = %w(FREQ_NGO PERFORMANCE MACRO_DOMAIN CRS_RICLASS YEAR_PROGR FOCAL_SECTOR PROD_FOCUS  TYPE_BF MARKET_VAR NEW_GRADE NEW_GRADE_SIMPLIFIED).map(&:downcase).map(&:to_sym)
FIELDS2 = FIELDS + ["domain", "year"]