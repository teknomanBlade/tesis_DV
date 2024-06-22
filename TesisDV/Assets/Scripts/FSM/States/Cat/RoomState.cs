using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoomState : IState
{
    private StateMachine _fsm;
    private Cat _cat;
    private int _currentPathWaypoint;

    public RoomState(StateMachine fsm, Cat p)
    {
        _fsm = fsm;
        _cat = p;
    }

    public void OnStart()
    {
        Debug.Log("Entré a RoomState");
    }

    public void OnUpdate()
    {
        if(_cat.canMove)
        {
            _cat.EnterWalkingState();

            Vector3 dir = _cat.Path[_currentPathWaypoint].transform.position - _cat.transform.position;

            Vector3 aux = dir;
            dir = new Vector3 (aux.x , aux.y, aux.z);
            _cat.transform.forward = dir;
            _cat.transform.position += _cat.transform.forward * _cat._walkingSpeed * Time.deltaTime;

            if (dir.magnitude < 0.4f)
            {
                _currentPathWaypoint++;
                //if (_currentPathWaypoint > _cat.Path.Count - 1)
                //{
                if(Vector3.Distance(_cat.transform.position, _cat._startingPosition) < 1f)
                {
                    _cat._navMeshAgent.enabled = true;
                    _fsm.ChangeCatState(CatStatesEnum.IdleState);
                }
                //}
            }
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de RoomState");
    }
}
