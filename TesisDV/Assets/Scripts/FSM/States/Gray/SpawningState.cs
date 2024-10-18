using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawningState : IState
{
    private StateMachine _fsm;
    private Enemy _enemy;
    private EnemyStatesEnum _transitionState;

    public SpawningState(StateMachine fsm, Enemy p, EnemyStatesEnum transitionState)
    {
        _fsm = fsm;
        _enemy = p;
        _transitionState = transitionState;
    }

    public void OnStart()
    {
        Debug.Log("Entre a SpawningState");
    }
    public void OnUpdate()
    {
        RaycastHit hit;
        Physics.Raycast(_enemy.transform.position, Vector3.down, out hit, Mathf.Infinity, GameVars.Values.GetFloorLayerMask());
        
        if (hit.distance <= 0.3f)
        {
            _fsm.ChangeState(_transitionState);
            _enemy.ReferenceEvent(true); //Activamos el Bool de Walk en el Animator.
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de SpawningState");
    }
}