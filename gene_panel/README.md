
# Gene Panels

Login to apocrita:
```
ssh apocrita
```

Go to where you want to do your work:
```
cd ~/Tom
```

If `samples.txt` exists and contains the samples you want to process:

```
cd ~/Tom
for x in `cat samples.txt`
do
  qsub $SCRIPTS/apocrita_NGS/gene_panel/gene_panel.sh $x
done
```

To track your job status:
```
qstat
```

You should see the `.o*` and `.e*` files appearing:
```
l
```

Once jobs are finished go to output directory:

```
cd ~/Blizard-BoneMarrowFailure/csv/b37/gene_panel/
```

The `*.hg19_multianno.csv` files should have been generated there:
```
l *.hg19_multianno.csv
```

In order to merge the files to produce `hg19_multianno_merged.csv`, run the following command in that directory:
```
cd ~/Blizard-BoneMarrowFailure/csv/b37/gene_panel/
Rscript $SCRIPTS/apocrita_NGS/gene_panel/merge_multianno.R
```





