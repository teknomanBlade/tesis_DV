using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EnemyStatesEnum
{
    SpawningState,
    ChaseState,
    CatState,
    PlayerState,
    AttackPlayerState,
    ChaseTrapState,
    AttackTrapState,
    AttackForceFieldState,
    ChaseForceFieldState,
    EscapeState,
    ProtectState,
    PathfindingState,
    TallGrayAttackState,
    TallGrayEscapeState,
    HardcodeCatState,
    HardcodeAttackState
}

public enum CatStatesEnum
{
    IdleState,
    WalkingState,
    TakenState
}

public class StateMachine
{
    IState _currentState = new BlankState();
    Dictionary<EnemyStatesEnum, IState> _allStates = new Dictionary<EnemyStatesEnum, IState>();
    Dictionary<CatStatesEnum, IState> _allCatStates = new Dictionary<CatStatesEnum, IState>();

    public void OnUpdate()
    {
        _currentState.OnUpdate();
    }

    public void ChangeState(EnemyStatesEnum id)
    {
        if (!_allStates.ContainsKey(id)) return;

        _currentState.OnExit();
        _currentState = _allStates[id];
        _currentState.OnStart();
    }

    public void AddState(EnemyStatesEnum id, IState state)
    {
        if (_allStates.ContainsKey(id)) return;
        _allStates.Add(id, state);
    }

    public void ChangeCatState(CatStatesEnum id)
    {
        if (!_allCatStates.ContainsKey(id)) return;

        _currentState.OnExit();
        _currentState = _allCatStates[id];
        _currentState.OnStart();
    }

    public void AddCatState(CatStatesEnum id, IState state)
    {
        if (_allCatStates.ContainsKey(id)) return;
        _allCatStates.Add(id, state);
    }
}
