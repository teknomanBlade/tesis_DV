using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProtectState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;

    public ProtectState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a Protect");
        _enemy.GetProtectTarget();

        //var dir = _enemy._target.transform.position - _enemy.transform.position;  Probar estos dos despues
        //_enemy.transform.forward = dir;                                           Probar estos dos despues


        //_enemy.ResetPathAndSetObjective(_enemy._target.transform.position);
    }
    public void OnUpdate()
    {
        //float distanceToTarget = Vector3.Distance(_enemy.transform.position, _enemy._target.transform.position);
        //Les cuesta tomar el target de nuevo cuando su primer target desaparece. Por ahora funciona pero despues se podria usar el target para
        //que se muevan hacia el cuando el NavmeshPath no sea valido. Para que no se queden duros en el lugar.
        //_enemy.Move();

        _enemy._circlePos = AIManager.Instance.RequestPosition(_enemy);

        if(Vector3.Distance(_enemy.transform.position, _enemy._circlePos) > 0.1f)
        {
            _enemy.ResetPathAndSetObjective(_enemy._circlePos);
        }

        //if (distanceToTarget > _enemy.protectDistance)
        //{
            //_enemy.ResetPathAndSetObjective(_enemy._target.transform.position);
        //} 

        if (!_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.pursueThreshold) //Agregar Raycast para ver al player
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseState);
        }
        
    }
    public void OnExit()
    {
        Debug.Log("Sali de Protect");
    }
}