using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WalkingState : IState
{
    private StateMachine _fsm;
    private Cat _cat;

    public WalkingState(StateMachine fsm, Cat p)
    {
        _fsm = fsm;
        _cat = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a WalkingState");
        _cat.EnterWalkingState();
    }

    public void OnUpdate()
    {
        if (Vector3.Distance(_cat.transform.position, _cat.StartingPosition) > 1f)
        {
            Vector3 dest = default(Vector3);
            dest = _cat.StartingPosition;
            var dir = dest - _cat.transform.position;
            dir.y = 0f;

            _cat._navMeshAgent.speed = _cat._walkingSpeed;
            _cat._navMeshAgent.destination = dest;
        }
        else
        {
            _fsm.ChangeCatState(CatStatesEnum.IdleState);
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de WalkingState");
    }
}