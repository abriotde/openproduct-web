#!/bin/env julia
using ArgParse
import JSON, MySQL, DBInterface

global const SIMULMODE::Bool = false
global const DEBUG::Bool = false


include("connect.jl")

OpenProduct.query_gogocarto("openproduct")

DBInterface.close!(dbConnection)

