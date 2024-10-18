using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class RunningState : IState
{
    private StateMachine _fsm;
    private Cat _cat;

    public RunningState(StateMachine fsm, Cat p)
    {
        _fsm = fsm;
        _cat = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a RunningState");
        _cat._navMeshAgent.enabled = true;
        _cat.EnterRunningState();
    }

    public void OnUpdate()
    {
        Debug.Log("Estoy en RunningState");
        if (Vector3.Distance(_cat.transform.position, _cat.StartingPosition) > 1f)
        {
            Vector3 dest = default(Vector3);
            dest = _cat.StartingPosition;
            var dir = dest - _cat.transform.position;
            dir.y = 0f;

            _cat._navMeshAgent.speed = _cat._runningSpeed;
            _cat._navMeshAgent.destination = dest;
        }
        else
        {
            _fsm.ChangeCatState(CatStatesEnum.IdleState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de RunningState");
    }
}
