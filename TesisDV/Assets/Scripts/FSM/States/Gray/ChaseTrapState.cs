using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChaseTrapState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public ChaseTrapState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a ChaseTrapState");

        _enemy.SetObjective(_enemy._currentTrapObjective.gameObject);
        _enemy.ResetPathAndSetObjective();
    }
    public void OnUpdate()
    {
        _enemy.Move();

        if(Vector3.Distance(_enemy._currentTrapObjective.transform.position, _enemy.transform.position) < _enemy.attackThreshold)
        {
            _fsm.ChangeState(EnemyStatesEnum.AttackTrapState);
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de ChaseTrapState");
    }
}
