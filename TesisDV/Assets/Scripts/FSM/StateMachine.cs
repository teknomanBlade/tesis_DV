using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EnemyStatesEnum
{
    ChaseState,
    CatState,
    AttackPlayerState,
    ChaseTrapState,
    AttackTrapState,
    EscapeState
}

public class StateMachine
{
    IState _currentState = new BlankState();
    Dictionary<EnemyStatesEnum, IState> _allStates = new Dictionary<EnemyStatesEnum, IState>();

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
}
