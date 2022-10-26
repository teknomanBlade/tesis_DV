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
        _currentPathWaypoint = 0;
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
        _enemy.DetectTraps();

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
        //_enemy.ResetPathAndSetObjective(_enemy._cat.transform.position);
        //_enemy.Move(); Probemos sin move a ver que onda.
        

        RaycastHit hit;
        Vector3 catDir = _enemy._cat.transform.position - _enemy.transform.position;
        Vector3 moveDir;
        if(myPath != null && Physics.Raycast(_enemy.transform.position, catDir, out hit, catDir.magnitude, GameVars.Values.GetWallLayerMask()) == true)
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
                        Debug.Log("No encontré mi objetivo, recalculando.");
                        _currentPathWaypoint = 0;
                        GetThetaStar();
                    }
                }
            }
        }
        else
        {
            Vector3 aux = catDir;
            catDir = new Vector3(aux.x, 0f, aux.z);
            _enemy.transform.forward = catDir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
        }


    }
    public void OnExit()
    {
        Debug.Log("Sali de CatState");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        //startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        startingPoint = _enemy._pfManager.GetClosestNode(_enemy.transform.position);
        //Debug.Log("Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();
        
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._player.transform);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._cat.transform.position);
        endingPoint = _enemy._pfManager.GetClosestNode(_enemy._cat.transform.position);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._exitPos); //el nodo final es personalizado de cada estado.
        //Debug.Log("End at " + endingPoint);
        //}

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
    }
}

