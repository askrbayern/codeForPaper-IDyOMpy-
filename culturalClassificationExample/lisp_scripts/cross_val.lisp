(start-idyom)
(idyom-db:import-data :mid "midis/bach/" "TEST_DATASET" 10)
(idyom:idyom 10 '(cpitch onset) '(cpitch onset) :models :both :k 5 :detail 3 :output-path "modelOutput/" :overwrite nil)
(quit)