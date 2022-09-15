using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChaseState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public ChaseState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a Chase");
        //_enemy.SetObjective(_enemy._player.gameObject);
        //_enemy.ResetPathAndSetObjective(_enemy._player.transform.position);

        //_enemy.ResetPathAndSetObjective(_enemy._player.transform.position); Ahora usamos el GetPlayerPos para que los aliens no se queden duros cuando subis a algun lugar
        _enemy.ResetPathAndSetObjective(_enemy.GetPlayerPos());
    }

    public void OnUpdate()
    {
        //_enemy.ResetPathAndSetObjective(_enemy._player.transform.position); Ahora usamos el GetPlayerPos para que los aliens no se queden duros cuando subis a algun lugar
        _enemy.ResetPathAndSetObjective(_enemy.GetPlayerPos());
        _enemy.Move();
        _enemy.DetectTraps();

        if (Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) > _enemy.disengageThreshold)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        else if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold)
        {
            _fsm.ChangeState(EnemyStatesEnum.AttackPlayerState);
        }
        else if(_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseTrapState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de Chase");
    }
}