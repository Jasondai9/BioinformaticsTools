from sklearn.neighbors import KernelDensity
import numpy as np
import pandas as pd


fname="sex_ratios.txt"

all_data = pd.read_csv(fname, delimiter="\t")

ratios = all_data['Ratio'].values.tolist()

N=100
np.random.seed(1)
X = np.concatenate((np.random.normal(0, 1, int(0.3 * N)),np.random.normal(5, 1, int(0.7 * N))))[:, np.newaxis]

#print(ratios)
ratio_array = np.array(ratios)
print(ratio_array)

for kernel in ['gaussian', 'tophat', 'epanechnikov']:
	kde = KernelDensity(kernel=kernel, bandwidth=0.5).fit(ratio_array)

#kmeans = KMeans(n_clusters=2, random_state=0).fit(ratios)
#print(kmeans)

#KMeans(n_clusters=2)
