using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TallGrayEscapeState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public TallGrayEscapeState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;
        
        GetThetaStar();
        Debug.Log("Entre a TallGrayEscapeState");
        
        //_enemy.SetObjective(_enemy.currentExitUFO);
        //_enemy.ResetPathAndSetObjective(_enemy._exitPos);
        var dir = _enemy._exitPos - _enemy.transform.position;
        _enemy.transform.forward = dir;
        //_enemy.ResetPathAndSetObjective(_enemy._exitPos);
    }
    public void OnUpdate()
    {
        //_enemy.ResetPathAndSetObjective(_enemy._exitPos);
        //_enemy.Move();

        if (_enemy.hasObjective) _enemy.EscapeWithCat(); //En teoría que esto sea un if ahora no tiene sentido porque siempre va a ser true, despues lo saco y pruebo.

        RaycastHit hit;
        Vector3 escapeDir = _enemy._exitPos - _enemy.transform.position;                                            //usamos obstacle mask ahora.
        if(myPath != null  && Physics.Raycast(_enemy.transform.position, escapeDir, out hit, escapeDir.magnitude, _enemy.obstacleMask) == true)
        {
            if(myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                _enemy.transform.forward = dir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

                if (dir.magnitude < 0.4f)
                {
                    _currentPathWaypoint++;
                    if (_currentPathWaypoint > myPath.Count - 1)
                    {
                        Debug.Log("No encontré mi objetivo, recalculando.");
                        _currentPathWaypoint = 0;
                        GetThetaStar();
                    }
                }
            }
        }
        else
        {
            _enemy.transform.forward = escapeDir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
        }

        if (_enemy._player.isAlive)
        {
            _fsm.ChangeState(EnemyStatesEnum.PlayerState);
        }
    }
    public void OnExit()
    {
        Debug.Log("TallGrayEscapeState");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        //startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        startingPoint = _enemy._pfManager.GetClosestNode(_enemy.transform.position);
        //Debug.Log("Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();
        
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._exitPos); //el nodo final es personalizado de cada estado.
        endingPoint = _enemy._pfManager.GetClosestNode(_enemy._exitPos);
        //Debug.Log("End at " + endingPoint);
        //}

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath);
    }
}