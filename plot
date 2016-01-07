#!/usr/bin/env python


def plot(input):
    import os
    import numpy as np
    from deepjets import generate
    from deepjets.preprocessing import preprocess
    from deepjets.utils import plot_jet_image, jet_mass
    from matplotlib import pyplot as plt
    import h5py
    
    print("plotting {0} ...".format(input))

    eta_edges = np.linspace(-1.3, 1.3, 26)
    phi_edges = np.linspace(-1.3, 1.3, 26)
    pixels = np.zeros((len(eta_edges) - 1, len(phi_edges) - 1))

    h5file = h5py.File(input, 'r')
    dset_images = h5file['images']
    output_prefix = os.path.splitext(input)[0]

    # plot jet images
    fig = plt.figure(figsize=(6, 5))
    ax = fig.add_subplot(111)
    avg_image = dset_images['image'].sum(axis=0) / len(dset_images)
    plot_jet_image(ax, avg_image, eta_edges, phi_edges, vmax=1e-2)
    fig.tight_layout()
    fig.savefig(output_prefix + '.png')

    # plot
    fig = plt.figure(figsize=(5, 5))
    ax  = fig.add_subplot(111)
    ax.hist(dset_images['mass'], bins=np.linspace(0, 120, 20),
            histtype='stepfilled', facecolor='none', edgecolor='blue')
    fig.tight_layout()
    plt.savefig(output_prefix + '_jet_mass.png')

    fig = plt.figure(figsize=(5, 5))
    ax  = fig.add_subplot(111)
    ax.hist(dset_images['pT'], bins=np.linspace(0, 600, 100),
            histtype='stepfilled', facecolor='none', edgecolor='blue')
    fig.tight_layout()
    plt.savefig(output_prefix + '_jet_pt.png')


if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('-n', type=int, default=-1)
    parser.add_argument('files', nargs='+')
    args = parser.parse_args()

    from deepjets.parallel import map_pool, FuncWorker

    map_pool(
        FuncWorker, [(plot, filename) for filename in args.files],
        n_jobs=args.n)
