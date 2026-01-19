# PendulePhysic

```
📁 PendulePhysic
├── 📁 doc         
│    ├──📄CPI_ProjetPendule.pdf     #Assignment
│    └──📄doc.md                    #Some doc
│
├── 📁 images    
│  
├── 📁 src
│    ├──📁 Other                    
│    │   ├── 📄 Predicition4sec.jl  #Simulation prediction
│    │   ├── 📄 Simple_pendule.jl   #Simple pendule
│    │   └── 📄 tracker_sim.jl      #Simulation tracker
│    ├──📄 data.csv                 #Data from tracker
│    └──📄 Double_pendule.jl        #Double pendule
│
├── 📁 tracker
│    └──📄 physique_tracker.trk     #Tracker 
│
└── 📁 video                        
     ├──📄 First_Video_2s.mp4       #Video model
     ├──📄 Pendule.mp4              #Video comparaison
     └──📄 prediction4sec.mp4       #Video prediction
```

## Setup

```
julia

]

activate .


instantiate
```

To start Double_pendule.jl `alt+enter`

## Initials parameters

- l1 = 0.09174
- l2 = 0.06933

## Tracker

Tracked point of the video with Tracker \
https://opensourcephysics.github.io/tracker-website/

## Positions comparaison

![Positions comparaions](images/Position.png)

Error NRMSE : 30.198642125055535 %


## Video comparaison
https://github.com/user-attachments/assets/7a7779fa-5f25-476c-bd03-d2e7725d95ea

## Video predicition

https://github.com/user-attachments/assets/9583b668-d972-49e3-9a50-6802a0f9044d