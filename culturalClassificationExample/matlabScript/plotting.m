%IDyOM Lisp
Cc_lisp = load(folder_IDyOMLisp + "modelOutput/Chinese_train_cross_val.mat");
Cb_lisp = load(folder_IDyOMLisp + "modelOutput/Chinese_train_trained_on_Bach_Pearce.mat");
Bc_lisp = load(folder_IDyOMLisp + "modelOutput/Bach_Pearce_cross_eval.mat");
Bch_lisp = load(folder_IDyOMLisp + "modelOutput/Bach_Pearce_trained_on_Chinese_train.mat");


score_idyom_lisp= clustering_eval(Cc_lisp, Cb_lisp, Bc_lisp, Bch_lisp);