using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChaseTrapState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public ChaseTrapState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a ChaseTrapState");

        //_enemy.SetObjective(_enemy._currentTrapObjective.gameObject);
        _enemy.ResetPathAndSetObjective(_enemy._currentTrapObjective.transform.position);
    }
    public void OnUpdate()
    {
        _enemy.ResetPathAndSetObjective(_enemy._currentTrapObjective.transform.position);
        _enemy.Move();
        
        if(!_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        if(_enemy._currentTrapObjective.GetComponent<BaseballLauncher>().active == false)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
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
