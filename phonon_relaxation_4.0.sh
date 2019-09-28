#! /bin/bash
  
## Used for phonon relaxation calculation.
## Written by Songwei Liu, in 2019-08-30.

fin=" writing wavefunctions"  # symbol of finishing relaxation run

mkdir ~/relaxed_structure_3.0

for i in omega
do
mkdir ~/phonon/${i}/relaxed_structure
mkdir ~/relaxed_structure_3.0/${i}_relaxed_structure

for j in 280 300
do
mkdir ~/phonon/${i}/phonon_${j}
cd ~/phonon/${i}/phonon_${j}

if [ ${i} == "alpha" ]
then
cat > INCAR <<!
PREC = Accurate
ENCUT = 400
LREAL = .False
ISTART = 0
ISMEAR = 1
SIGMA = 0.05
EDIFF = 1E-8
EDIFFG = -1E-3
NSW = 100
ISIF = 3
IBRION = 1
PSTRESS = ${j}
!
cat > KPOINTS <<!
coord.13.02
 0
Gamma point shift
 12 12 12
 0 0 0
!
elif [ ${i} == "beta" ]
then
cat > INCAR <<!
PREC = Accurate
ENCUT = 400
LREAL = .False
ISTART = 0
ISMEAR = 1
SIGMA = 0.05
EDIFF = 1E-8
EDIFFG = -1E-3
NSW = 100
ISIF = 3
ISYM = -1
IBRION = 2
PSTRESS = ${j}
!
cat > KPOINTS <<!
coord.13.02
 0
Gamma point shift
 12 12 12
 0 0 0
!
elif [ ${i} == "omega" ]
then
cat > INCAR <<!
PREC = Accurate
ENCUT = 400
LREAL = .False
ISTART = 0
ISMEAR = 1
SIGMA = 0.08
EDIFF = 1E-8
EDIFFG = -1E-3
NSW = 100
ISIF = 3
IBRION = 1
PSTRESS = ${j}
!
cat > KPOINTS <<!
coord.13.02
 0
Gamma point shift
 12 12 12
 0 0 0
!
fi

echo "${i}_${j}"

cp ~/phonon/potential/POTCAR_pv POTCAR
cp ~/phonon/potential/${i}_Ti.vasp POSCAR
time mpirun -n 4 /usr/local/bin/vasp5-intel-parallel > out 

a=`tail -n 1 out`
if test "${a}" = "${fin}"
then
    echo 'relaxation succeed'
    cp CONTCAR ~/phonon/${i}/relaxed_structure/POSCAR_unitcell_${j}
    cp CONTCAR ~/relaxed_structure_3.0/${i}_relaxed_structure/POSCAR_unitcell_${j}
else
    echo 'relaxation failed'
    echo "${a}"
fi

done

done

cd
tar -zcvf phonon.tar.gz phonon
cp ~/phonon.tar.gz ~/relaxed_structure_3.0/phonon.tar.gz
tar -zcvf relaxed_structure_3.0.tar.gz relaxed_structure_3.0

