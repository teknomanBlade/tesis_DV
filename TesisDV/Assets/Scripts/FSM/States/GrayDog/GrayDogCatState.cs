using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogCatState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public GrayDogCatState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }
    public void OnExit()
    {
        Debug.Log("Sali de GrayDogCatState");
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;
        //Estos if en el start deberían hacer que no carguemos un Path sin necesidad.

        if (_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.ProtectState);
        }

        GetThetaStar();
        Debug.Log("Entre a GrayDogCatState");
    }

    public void OnUpdate()
    {
        if (Vector3.Distance(_enemy.transform.position, _enemy._cat.transform.position) < 3f)//1f) Lo cambiamos hasta que el tallGray tenga la escala bien puesta.
        {
            _enemy.GrabCat();
            GameVars.Values.ShowNotification("The cat has been captured! You must prevent the grays getting to the ship!");

            _fsm.ChangeState(EnemyStatesEnum.GrayDogEscapeState);
        }
        else if (_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.ProtectState);
        }
        
        RaycastHit hit;
        Vector3 catDir = _enemy._cat.transform.position - _enemy.transform.position;
        Vector3 moveDir;
        //Usamos obstacle mask ahora.
        if (Physics.Raycast(_enemy.transform.position, catDir, out hit, catDir.magnitude, _enemy.obstacleMask) || Vector3.Distance(_enemy.transform.position, _enemy._cat.transform.position) >= 5)
        {
            if (myPath != null && myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                Vector3 aux = dir;
                dir = new Vector3(aux.x, aux.y, aux.z);
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
            else
            {
                GetThetaStar();
            }
        }
        else
        {
            Vector3 aux = catDir;
            catDir = new Vector3(aux.x, aux.y, aux.z);
            _enemy.transform.forward = catDir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
        }
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        //startingPoint = _enemy._pfManager.GetStartNode(_enemy.transform);
        startingPoint = PathfindingManager.Instance.GetClosestNode(_enemy.transform.position);
        //Debug.Log("Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();

        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._player.transform);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._cat.transform.position);
        endingPoint = PathfindingManager.Instance.GetClosestNode(_enemy._cat.transform.position);
        //endingPoint = _enemy._pfManager.GetEndNode(_enemy._exitPos); //el nodo final es personalizado de cada estado.
        //Debug.Log("End at " + endingPoint);
        //}

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
    }
}
