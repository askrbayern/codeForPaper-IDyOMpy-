import numpy as np
from tqdm import tqdm
import matplotlib.pyplot as plt
import scipy.io as sio
import pickle
import numpy as np
import scipy.io as sio


def toFloat(f):
	try:
		return float(f)
	except ValueError:
		return f

def getDico(file):
	f=open(file, "r")
	lines = f.readlines()
	dico = {}
	keys = lines[0].split()
	for i in tqdm(range(1, len(lines))):
		tmp = lines[i].split()

		if tmp[1] not in dico:
			dico[tmp[1]] = {}

		k = 0
		for key in keys:
			if key not in dico[tmp[1]]:
				dico[tmp[1]][key] = []
			dico[tmp[1]][key].append(toFloat(tmp[k]))
			k += 1

	return dico

def getLikelihood(D):

	likelihood = []

	for melody_id in D:
		tmp = []
		for note in D[melody_id]["probability"]:
			tmp.append(note)

		likelihood.append(np.mean(tmp))

	return np.mean(likelihood), np.std(likelihood), len(likelihood)
	print("likelihood:", np.mean(likelihood), "| std:", np.std(likelihood))

def getSurpriseValue(D):
	likelihoods = []
	files = []
	for melody_id in D:
		tmp = []
		for note in D[melody_id]["ic"]:
			tmp.append(note)

		likelihoods.append(np.mean(tmp))
		files.append(D[melody_id]["melody.name"][0][1:-1])

	surprises = {}
	for i in range(len(likelihoods)):
		surprises[files[i]] = np.array(likelihoods)

	return surprises

def getLikelihoods(D):

	likelihoods = []
	files = []
	for melody_id in D:
		tmp = []
		for note in D[melody_id]["probability"]:
			tmp.append(note)

		likelihoods.append(np.mean(tmp))
		files.append(D[melody_id]["melody.name"][0][1:-1])

	return likelihoods, files
	
def getSurprise(file):

	folder = file[:file.rfind("/")+1]

	D = getDico(file)
	likelihoods = {}

	for melody_id in D:
		tmp = []
		for note in D[melody_id]["probability"]:
			tmp.append(note)
		melody_name = D[melody_id]["melody.name"][0]
		melody_name = melody_name[1:melody_name.rfind(".mid")]
		likelihoods[melody_name] = -np.log(tmp)/np.log(2)

	return likelihoods

def getPitchIC(file):

	folder = file[:file.rfind("/")+1]

	D = getDico(file)
	likelihoods = {}

	for melody_id in D:
		tmp = []
		for note in D[melody_id]["cpitch.probability"]:
			tmp.append(note)
		melody_name = D[melody_id]["melody.name"][0]
		melody_name = melody_name[1:melody_name.rfind(".mid")]
		likelihoods[melody_name] = -np.log(tmp)/np.log(2)

	return likelihoods

def getPitchEntropy(file):

	folder = file[:file.rfind("/")+1]

	D = getDico(file)
	likelihoods = {}

	for melody_id in D:
		tmp = []
		for note in D[melody_id]["cpitch.entropy"]:
			tmp.append(note)
		melody_name = D[melody_id]["melody.name"][0]
		melody_name = melody_name[1:melody_name.rfind(".mid")]
		likelihoods[melody_name] = tmp

	return likelihoods

def save_IC_Entropy(file, file_out=""):

	folder = file[:file.rfind("/")+1]

	D = getDico(file)
	likelihoods = {}

	for melody_id in D:
		tmp_surprise = []
		tmp_entropy = []
		for note in D[melody_id]["ic"]:
			tmp_surprise.append(note)	

		for note in D[melody_id]["entropy"]:
			tmp_entropy.append(note)

		melody_name = D[melody_id]["melody.name"][0]
		melody_name = melody_name[1:melody_name.rfind(".mid")]
		melody_name = melody_name.replace("-", "_")
		likelihoods[melody_name] = np.array([tmp_surprise, tmp_entropy])

		if file_out == "":
			sio.savemat(file[:-3]+"mat", likelihoods)
		else:
			sio.savemat(file_out, likelihoods)


	return likelihoods


# S = getSurprise("../stimuli/giovanni/surprises/13-cpitch_onset-cpitch_onset-12-nil-melody-nil-1-both-nil-t-nil-c-nil-t-t-x-3.dat")
# D = getDico("../stimuli/giovanni/surprises/13-cpitch_onset-cpitch_onset-12-nil-melody-nil-1-both-nil-t-nil-c-nil-t-t-x-3.dat")
# L = getLikelihood(D)
# plt.plot(D['1']["probability"])
# plt.show()
