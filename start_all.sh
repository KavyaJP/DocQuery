#!/bin/bash

gnome-terminal -- bash -c "./backend/start_backend.sh; exec bash"
gnome-terminal -- bash -c "./frontend/start_frontend.sh; exec bash"