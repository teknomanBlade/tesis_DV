using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;
    
    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public CatState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        //Estos if en el start deberían hacer que no carguemos un Path sin necesidad.

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

        GetThetaStar();
        Debug.Log("Entre a CatState");

        //_enemy.SetObjective(_enemy._cat.gameObject); 
        //_enemy.ResetPathAndSetObjective(_enemy._cat.transform.position); Chau Navmesh
        //_enemy.ResetPathAndSetObjective();
    }
    public void OnUpdate()
    {
        //_enemy.ResetPathAndSetObjective(_enemy._cat.transform.position);
        //_enemy.Move(); Probemos sin move a ver que onda.
        _enemy.DetectTraps();

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

        if(Vector3.Distance(_enemy.transform.position, _enemy._cat.transform.position) < 1f) 
        {
            _enemy.GrabCat();
            GameVars.Values.ShowNotification("The cat has been captured! You must prevent the grays getting to the ship!");

            _fsm.ChangeState(EnemyStatesEnum.EscapeState); 
        }
        else if (_enemy._lm.enemyHasObjective)
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
    }
    public void OnExit()
    {
        Debug.Log("Sali de CatState");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        Debug.Log("Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();
        
        endingPoint = _enemy._pfManager.GetEndNode(_enemy._player.transform);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._cat.transform); //el nodo final es personalizado de cada estado.
        Debug.Log("End at " + endingPoint);
        //}

        myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        //myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
        Debug.Log(myPath);
    }
}

