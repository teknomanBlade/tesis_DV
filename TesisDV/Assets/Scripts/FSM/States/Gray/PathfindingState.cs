using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathfindingState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public PathfindingState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        GetThetaStar();
        Debug.Log("Entre a PathfindingState");
    }
    public void OnUpdate()
    {
        //_enemy._patrolPath = myPath;    Veremos si es necesario.
        _enemy.DetectTraps();
        //Poner que pasa en el medio.
        //Si detecta al enemigo, si detecta trampas, si se actualiza el bool de cuando se llevan al gato.

        if (_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.ProtectState);  
        }
        else if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.pursueThreshold) //Agregar Raycast para ver al player
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseState);
        }
        else if(_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseTrapState);
        }

        if(myPath != null)
        {
                if(myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                _enemy.transform.forward = dir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

                if (dir.magnitude < 0.1f)
                {
                    _currentPathWaypoint++;
                    if (_currentPathWaypoint > myPath.Count - 1)
                    {
                        //Ver a que estado cambiar una vez que llegamos.
                    }
                }
            }
        }
    }

    public void OnExit()
    {
        Debug.Log("Sali de PathfindingState");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        Debug.Log("Start at " + startingPoint);
        
        /* if(_enemy.alarmPosition != null)
        {
            endingPoint = _enemy._pfManager.GetEndNode(_enemy.alarmPosition);
        }
        else
        { */
            _currentWaypoint = _enemy.GetCurrentWaypoint();
        
            //endingPoint = _enemy._pfManager.GetEndNode(_enemy._waypoints[_currentWaypoint]); Esto se esta solucionando en cada estado (Cat, Protect, Escape)
            Debug.Log("End at " + endingPoint);
        //}

        myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
    }
}
