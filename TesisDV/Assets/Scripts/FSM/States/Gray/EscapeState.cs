using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EscapeState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public EscapeState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        GetThetaStar();
        Debug.Log("Entre a Escape");
        
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
                        Debug.Log("Nunca deberiamos llegar aca. Si estas viendo esto algo salio mal.");
                    }
                }
            }
        }

        if (Vector3.Distance(_enemy.transform.position, _enemy._exitPos) < 1.5f)
        {
            _enemy.GoBackToShip();
        }
        else if (!_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de Escape");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        Debug.Log("Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();
        
        endingPoint = _enemy._pfManager.GetEndNode(_enemy._cat.transform); //el nodo final es personalizado de cada estado.
        Debug.Log("End at " + endingPoint);
        //}

        myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
    }
}