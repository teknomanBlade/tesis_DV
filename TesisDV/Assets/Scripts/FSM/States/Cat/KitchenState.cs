using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class KitchenState : IState
{
    private StateMachine _fsm;
    private Cat _cat;
    private int _currentPathWaypoint;
    private List<Transform> _pathToKitchen;

    public KitchenState(StateMachine fsm, Cat p)
    {
        _fsm = fsm;
        _cat = p;
    }

    public void OnExit()
    {
        Debug.Log("Sal� de ShedState");
    }

    public void OnStart()
    {
        Debug.Log("Entr� a ShedState");
        _pathToKitchen = _cat.PathToKitchen;
    }

    public void OnUpdate()
    {
        if (_cat.canMove)
        {
            _cat.EnterWalkingState();

            Vector3 dir = _pathToKitchen[_currentPathWaypoint].transform.position - _cat.transform.position;

            Vector3 aux = dir;
            dir = new Vector3(aux.x, aux.y, aux.z);
            _cat.transform.forward = dir;
            _cat.transform.position += _cat.transform.forward * _cat._walkingSpeed * Time.deltaTime;

            if (dir.magnitude < 0.4f)
            {
                _currentPathWaypoint++;
                var last = _pathToKitchen.LastOrDefault();
                if (Vector3.Distance(_cat.transform.position, last.transform.position) < 1f)
                {
                    _cat._navMeshAgent.enabled = true;
                    _cat.IsGoingBack = false;
                    _cat.Renderers.ForEach(x =>
                    {
                        x.GetAStarPath();
                    });
                    _currentPathWaypoint = 0;
                    _fsm.ChangeCatState(CatStatesEnum.IdleState);
                }
            }
        }
    }

}