using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogEscapeState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public GrayDogEscapeState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;

        Debug.Log("Entre a GrayDogEscape");

        var dir = _enemy._exitPos - _enemy.transform.position;
        _enemy.transform.forward = dir;

        GetThetaStar();
    }
    public void OnUpdate()
    {
        if (Vector3.Distance(_enemy.transform.position, _enemy._exitPos) < 1.5f)
        {
            Debug.Log("ENTRA EN GO BACK TO SHIP?");
            _enemy.GoBackToShip();
        }
        else if (!_enemy._lm.enemyHasObjective)
        {
            Debug.Log("ENTRA EN GRAY DOG CAT STATE?");
            _fsm.ChangeState(EnemyStatesEnum.GrayDogCatState);
        }

        _enemy.EscapeWithCat();

        RaycastHit hit;
        Vector3 escapeDir = _enemy._exitPos - _enemy.transform.position;                                            //usamos obstacle mask ahora.
        if (myPath != null && Physics.Raycast(_enemy.transform.position, escapeDir, out hit, escapeDir.magnitude, _enemy.obstacleMask) == true)
        {
            if (myPath.Count >= 1)
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
    }
    public void OnExit()
    {
        Debug.Log("Sali de GrayDogEscape");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = PathfindingManager.Instance.GetClosestNode(_enemy.transform.position);
        Debug.Log("GrayDog Start at " + startingPoint);

        _currentWaypoint = _enemy.GetCurrentWaypoint();

        endingPoint = PathfindingManager.Instance.GetClosestNode(_enemy._exitPos);
        Debug.Log("GrayDog End at " + endingPoint);

        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath);
    }

}
