using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatState : IState
{
    private StateMachine _fsm;
    private GrayModel _enemy;

    public CatState(StateMachine fsm, GrayModel p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a CatState");

        _enemy.SetObjective(_enemy._cat.gameObject);
        //_enemy.ResetPathAndSetObjective(_enemy._cat.transform.position);
        _enemy.ResetPathAndSetObjective();
    }
    public void OnUpdate()
    {
        _enemy.Move();
        
        if(Vector3.Distance(_enemy.transform.position, _enemy._cat.transform.position) < 3f) 
        {
            _enemy.GrabCat();
            GameVars.Values.ShowNotification("The cat has been captured! You must prevent the grays getting to the ship!");
            _fsm.ChangeState(EnemyStatesEnum.EscapeState);
        }
        else if (_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.EscapeState);
        }
        else if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.pursueThreshold) //Agregar Raycast para ver al player
        {
            _fsm.ChangeState(EnemyStatesEnum.AttackPlayerState);
        }
        else if(_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.AttackTrapState);
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de CatState");
    }
}

