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
        //_enemy.ResetPathAndSetObjective(_enemy._currentTrapObjective.transform.position); //Se va el navmesh
    }
    public void OnUpdate()
    {
        //_enemy.ResetPathAndSetObjective(_enemy._currentTrapObjective.transform.position); //Se va el navmesh
        //_enemy.Move();
        
        Vector3 dir = _enemy._currentTrapObjective.transform.position - _enemy.transform.position;
        _enemy.transform.forward = dir;
        _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

        if(!_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        if(_enemy._currentTrapObjective.GetComponent<Trap>().active == false)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
            _enemy.foundTrapInPath = false;
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
