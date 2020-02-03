#!/usr/local/bin/python3

import matplotlib.pyplot as plt
import numpy as np
import sys
import os
import csv
import math
import pandas as pd

def print_usage():
    print ("%s <result-dir> [noshow]"%(sys.argv[0]))

if len(sys.argv) < 2:
    print_usage()
    exit()



result_dir=sys.argv[1]

showfig = True

if len(sys.argv) == 3 and sys.argv[2] == "noshow":
    showfig = False


def get_figure_dir(filename):
    dataname=os.path.basename(filename).split(".")[0]
    datapath=os.path.dirname(filename)
    result_dir=datapath + "/figures/"

    if not os.path.exists(result_dir):
        os.makedirs(result_dir)

    print("result_dir=",result_dir)

    return result_dir


def load_CSV_to_XY(csvfile):
    print("Loading data from %s ..."%(csvfile))

    Y=np.array([], dtype=np.double)

    f = file(csvfile)

    num = 1

    for line in f:

        record=line.split()

        Y.append(record)


    f.close()

    X = np.linspace(0, len(Y), len(Y))

    return (X, Y)


def draw_figure_rss(input_csvfile):

    X, Y = load_result_to_XY(input_csvfile)

    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + ".png"

    print("figure_file=",figure_file)

    fig = plt.figure(figsize=(10,6.18))

    #Y = Y / (max(Y) + 1e-3)

    plt.plot(X, Y, color='black', label="RSS")

    plt.legend(loc='best')


    plt.ylim(0, max(Y))
    plt.xlim(0, len(X))

    #plt.grid(True)

    plt.title("RSS Trends [%s]"%(basename))

    plt.xlabel("Time")
    plt.ylabel("RSS in KiB")


    x_ticks  = []
    x_labels = []

    plt.xticks(x_ticks, x_labels, rotation=45, fontsize='small')


    #
    # save to file
    #

    #plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file + " .")

    if showfig:
        plt.show()

    plt.close()

    return

def draw_figure_cpupower(csvfile):

    f = open(csvfile)
    csvreader = csv.reader(f, delimiter=',')

    Y_CPU0=[]
    Y_MEM0=[]

    Y_CPU1=[]
    Y_MEM1=[]

    header = f.readline()

    print("header=",header)

    for row in csvreader:
        #print(row)
        Y_CPU0.append(row[0])
        Y_MEM0.append(row[1])
        Y_CPU1.append(row[2])
        Y_MEM1.append(row[3])

    f.close()


    Y_CPU0 = np.array(Y_CPU0, dtype=np.double)
    Y_CPU1 = np.array(Y_CPU1, dtype=np.double)

    Y_MEM0 = np.array(Y_MEM0, dtype=np.double)
    Y_MEM1 = np.array(Y_MEM1, dtype=np.double)

    X = np.linspace(0, len(Y_CPU0), len(Y_CPU0))

    fig = plt.figure(figsize=(10,6.18))


    #plt.plot(X, Y1, color='black', linestyle='-', marker='x', label="CPU0")
    #plt.plot(X, Y2, color='red',   linestyle='-', marker='+', label="CPU1")

    plt.plot(X, Y_CPU0, color='black', linestyle='-', label="CPU0")
    plt.plot(X, Y_CPU1, color='red',   linestyle='-', label="CPU1")

    plt.plot(X, Y_MEM0, color='black', linestyle='-.', label="MEM0")
    plt.plot(X, Y_MEM1, color='red',   linestyle='-.', label="MEM0")

    plt.legend(loc='best')

    Y_MAX=[max(Y_CPU0), max(Y_CPU1), max(Y_MEM0), max(Y_MEM1)]


    #print("max y:",max(Y_MAX))

    plt.ylim(0, max(Y_MAX))
    plt.xlim(0, len(X))

    #plt.grid(True)

    plt.title("Hardware power consumption (Watts)")

    plt.xlabel("Time")
    plt.ylabel("Watts")


    x_ticks  = []
    x_labels = []

    plt.xticks(x_ticks, x_labels, rotation=45, fontsize='small')


    #
    # save to file
    #

    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + ".png"

    plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file)

    #if showfig:
    #plt.show()

    plt.close()


    return


def draw_figure_cpucache(csvfile):

    f = open(csvfile)
    csvreader = csv.reader(f, delimiter=',')

    Y1=[]
    Y2=[]

    header = f.readline()

    print("header=",header)

    for row in csvreader:
        Y1.append(row[0])
        Y2.append(row[1])

    f.close()


    if len(Y1) == 0 or len(Y2) == 0:
        return

    Y1 = np.array(Y1, dtype=np.double)
    Y2 = np.array(Y2, dtype=np.double)

    X = np.linspace(0, len(Y1), len(Y1))

    fig = plt.figure(figsize=(10,6.18))


    #plt.plot(X, Y1, color='black', linestyle='-', marker='x', label="CPU0")
    #plt.plot(X, Y2, color='red',   linestyle='-', marker='+', label="CPU1")

    plt.plot(X, Y1, color='black', linestyle='-', label="CPU0 misses")
    plt.plot(X, Y2, color='red',   linestyle='-', label="CPU1 misses")

    plt.legend(loc='best')

    Y_MAX=[max(Y1), max(Y2)]

    plt.ylim(0, max(Y_MAX))
    plt.xlim(0, len(X))

    #plt.grid(True)

    plt.title("CPU Cache Misses Latency (nS)")

    plt.xlabel("Time")
    plt.ylabel("Latency (nS)")


    x_ticks  = []
    x_labels = []

    plt.xticks(x_ticks, x_labels, rotation=45, fontsize='small')


    #
    # save to file
    #

    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + ".png"

    plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file)

    #if showfig:
    #plt.show()

    plt.close()


    return

def draw_figure_general(csvfile, title, legend, xlabel, ylabel, color, linestyle):

    f = open(csvfile)
    csvreader = csv.reader(f, delimiter=',')

    Y=[]

    header = f.readline()

    print("header=",header)

    for row in csvreader:
        Y.append(row[0])

    f.close()

    if len(Y) == 0:
        return

    Y = np.array(Y, dtype=np.double)

    X = np.linspace(0, len(Y), len(Y))

    fig = plt.figure(figsize=(10,6.18))


    plt.plot(X, Y, color=color, linestyle=linestyle, label=legend)

    plt.legend(loc='best')

    plt.ylim(0, max(Y))
    plt.xlim(0, len(X))

    #plt.grid(True)

    plt.title(title)

    plt.xlabel(xlabel)
    plt.ylabel(ylabel)


    x_ticks  = []
    x_labels = []

    plt.xticks(x_ticks, x_labels, rotation=45, fontsize='small')


    #
    # save to file
    #

    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + ".png"

    plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file)

    #if showfig:
    #plt.show()

    plt.close()



    return

def draw_figure_memorybandwidth(csvfile):

    f = open(csvfile)
    csvreader = csv.reader(f, delimiter=',')

    Y_S0R=[]
    Y_S0W=[]

    Y_S1R=[]
    Y_S1W=[]

    header = f.readline()

    print("header=",header)

    for row in csvreader:
        #print(row)
        Y_S0R.append(row[3])
        Y_S0W.append(row[4])
        Y_S1R.append(row[15])
        Y_S1W.append(row[16])

    f.close()


    Y_S0R = np.array(Y_S0R, dtype=np.double)
    Y_S0W = np.array(Y_S0W, dtype=np.double)

    Y_S1R = np.array(Y_S1R, dtype=np.double)
    Y_S1W = np.array(Y_S1W, dtype=np.double)

    X = np.linspace(0, len(Y_S0R), len(Y_S0R))

    fig = plt.figure(figsize=(10,6.18))


    #plt.plot(X, Y1, color='black', linestyle='-', marker='x', label="CPU0")
    #plt.plot(X, Y2, color='red',   linestyle='-', marker='+', label="CPU1")

    plt.plot(X, Y_S0R, color='black', linestyle='-', label="socket_0_read")
    plt.plot(X, Y_S0W, color='red',   linestyle='-', label="socket_0_write")

    plt.plot(X, Y_S1R, color='black', linestyle='-.', label="socket_1_read")
    plt.plot(X, Y_S1W, color='red',   linestyle='-.', label="socket_1_write")

    plt.legend(loc='best')

    Y_MAX=[max(Y_S0R), max(Y_S0W), max(Y_S1R), max(Y_S1W)]


    #print("max y:",max(Y_MAX))

    plt.ylim(0, max(Y_MAX))
    plt.xlim(0, len(X))

    #plt.grid(True)

    plt.title("Memory bandwidth consumption (MB)")

    plt.xlabel("Time")
    plt.ylabel("MB")


    x_ticks  = []
    x_labels = []

    plt.xticks(x_ticks, x_labels, rotation=45, fontsize='small')


    #
    # save to file
    #

    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + ".png"

    plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file)

    #if showfig:
    #plt.show()

    plt.close()


    return

def draw_figure_bandwidth_breakdown_read(csvfile):

    f = open(csvfile)
    csvreader = csv.reader(f, delimiter=',')

    Y_S0C0R=[]
    Y_S0C1R=[]
    Y_S0C2R=[]
    Y_S0C3R=[]

    header = f.readline()

    print("header=",header)

    for row in csvreader:
        Y_S0C0R.append(row[7])
        Y_S0C1R.append(row[9])
        Y_S0C2R.append(row[11])
        Y_S0C3R.append(row[13])
    f.close()

    Y_S0C0R = np.array(Y_S0C0R, dtype=np.double)
    Y_S0C1R = np.array(Y_S0C1R, dtype=np.double)
    Y_S0C2R = np.array(Y_S0C2R, dtype=np.double)
    Y_S0C3R = np.array(Y_S0C3R, dtype=np.double)

    X = np.linspace(0, len(Y_S0C0R), len(Y_S0C0R))
    fig = plt.figure(figsize=(10,6.18))

    plt.stackplot(X, Y_S0C0R, Y_S0C1R, Y_S0C2R, Y_S0C3R, labels=['socket_0_channel_0_read','socket_0_channel_1_read','socket_0_channel_2_read','socket_0_channel_3_read'])
    plt.title("Memory read bandwidth consumption breakdown(MB)")
    plt.xlabel("Time")
    plt.ylabel("MB")
    plt.legend(loc='upper left')
    plt.tight_layout()

    #save figure
    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + "read.png"

    plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file)

    plt.close()


def draw_figure_bandwidth_breakdown_write(csvfile):
    f = open(csvfile)
    csvreader = csv.reader(f, delimiter=',')

    Y_S0C0W=[]
    Y_S0C1W=[]
    Y_S0C2W=[]
    Y_S0C3W=[]

    header = f.readline()

    print("header=",header)

    for row in csvreader:
        Y_S0C0W.append(row[8])
        Y_S0C1W.append(row[10])
        Y_S0C2W.append(row[12])
        Y_S0C3W.append(row[14])
    f.close()

    Y_S0C0W = np.array(Y_S0C0W, dtype=np.double)
    Y_S0C1W = np.array(Y_S0C1W, dtype=np.double)
    Y_S0C2W = np.array(Y_S0C2W, dtype=np.double)
    Y_S0C3W = np.array(Y_S0C3W, dtype=np.double)

    X = np.linspace(0, len(Y_S0C0W), len(Y_S0C0W))
    fig = plt.figure(figsize=(10,6.18))

    plt.stackplot(X, Y_S0C0W, Y_S0C1W, Y_S0C2W, Y_S0C3W, labels=['socket_0_channel_0_write','socket_0_channel_1_write','socket_0_channel_2_write','socket_0_channel_3_write'])
    plt.title("Memory write bandwidth consumption breakdown(MB)")
    plt.xlabel("Time")
    plt.ylabel("MB")
    plt.legend(loc='upper left')
    plt.tight_layout()

    #save figure
    figure_dir=get_figure_dir(csvfile)

    basename=os.path.basename(csvfile).split(".")[0]

    figure_file=figure_dir + "/" + basename + "write.png"

    plt.savefig(figure_file, dpi=600)

    print("Diagram is saved to " + figure_file)

    plt.close()



for root, dirs, files in os.walk(result_dir, topdown=True):
    for name in files:
        #print(os.path.join(root, name))

        name=os.path.basename(name)

        if len(name.split('.')) == 2 and  name.split('.')[1] == "csv":
            csvfile=os.path.join(root, name)
            #print("name=",name)
            print("csvfile=",csvfile)

            if name == "pcm_latency.csv":
                draw_figure_cpucache(csvfile)

            if name == "pcm_memory.csv":
                #draw_figure_memorybandwidth(csvfile)
                #draw_figure_bandwidth_breakdown_read(csvfile)
                draw_figure_bandwidth_breakdown_write(csvfile)

            if name == "appoutput.csv":
                draw_figure_general(    csvfile,
                                        title='Iteration time',
                                        legend='Iteration time',
                                        xlabel='Time',
                                        ylabel='Seconds',
                                        color='black',
                                        linestyle='-'
                                        )


            if name == "numastat.csv":
                draw_figure_general(    csvfile,
                                        title='UsedMemory (MiB)',
                                        legend='MemUsed',
                                        xlabel='Time',
                                        ylabel='MiB',
                                        color='black',
                                        linestyle='-'
                                        )
