using StaticArrays, Plots, HybridSystems

# At this point, we import the useful Dionysos sub-modules.
using Dionysos
const DI = Dionysos
const UT = DI.Utils
const DO = DI.Domain
const ST = DI.System
const SY = DI.Symbolic
const OP = DI.Optim
const AB = OP.Abstraction

# we can import the module containing the FlowShopScheduling3D problem like this
include(
    joinpath(dirname(dirname(pathof(Dionysos))), "problems", "flowshopscheduling_3D.jl"),
);

# generate the concrete hybrid system and the problem specifications
HybridSystem_automaton, growth_bounds, discretization_parameters, problem_specs =
    FlowShopScheduling3D.generate_system_and_problem()

# get the concrete_controller using Dionysos
concrete_controller = AB.TemporalHybridSymbolicModelAbstraction.solve(
    HybridSystem_automaton,
    growth_bounds,
    discretization_parameters,
    problem_specs,
)

# get closed loop trajectory using the concrete_controller
traj, ctrls = AB.TemporalHybridSymbolicModelAbstraction.get_closed_loop_trajectory(
    discretization_parameters,
    HybridSystem_automaton,
    problem_specs,
    concrete_controller,
    problem_specs.initial_state,
    1000000;
    stopping = AB.TemporalHybridSymbolicModelAbstraction.reached,
)

# Display trajectory and controls 
for (idx, (t, u)) in enumerate(zip(traj, ctrls))
    println("[", idx, "] state: ", t, " - control applied: ", u)
end
println("Final state: ", traj[end])