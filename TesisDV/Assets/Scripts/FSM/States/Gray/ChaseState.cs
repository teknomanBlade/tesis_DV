using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChaseState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public ChaseState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a Chase");
        _enemy.SetObjective(_enemy._player.transform.position);
        _enemy.ResetPathAndSetObjective(_enemy._player.transform.position);
    }

    public void OnUpdate()
    {
        _enemy.Move();

        if (Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) > _enemy.disengageThreshold)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }

        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold)
        {
            _fsm.ChangeState(EnemyStatesEnum.AttackPlayerState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de Chase");
    }
}