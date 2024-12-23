using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;
    
    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    private bool _needsPathfinding = false;

    public PlayerState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;

        GetThetaStar();
        Debug.Log("Entre a PlayerState");
    }
    public void OnUpdate()
    {
        _enemy.DetectForceFields();

        if(!_enemy._player.isAlive)
        {
            _fsm.ChangeState(EnemyStatesEnum.TallGrayEscapeState);
        }

        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold && _enemy._player.isAlive)
        {
            _fsm.ChangeState(EnemyStatesEnum.TallGrayAttackState);
        }
        else if(_enemy.foundTrapInPath)
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseForceFieldState);
        }

        RaycastHit hit;
        Vector3 playerDir = _enemy._player.transform.position - _enemy.transform.position;                                                                             //Usamos obstacle mask ahora.
        if(myPath != null && Physics.Raycast(_enemy.transform.position, playerDir, out hit, playerDir.magnitude, _enemy.obstacleMask) == true) // || Vector3.Distance(_enemy.transform.position, _enemy._player.transform.position) >= _enemy.pursueThreshold)
        {
            if(_needsPathfinding)
            {
                GetThetaStar();
                _needsPathfinding = false;
            }
            if(myPath != null && myPath.Count >= 1 && _currentPathWaypoint < myPath.Count)
            {
                //Debug.Log("GRAY TALL PATH COUNT: " + myPath.Count);
                //Debug.Log("CURRENT PATH WAYPOINT: " + _currentPathWaypoint);
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                Vector3 aux = dir;
                dir = new Vector3 (aux.x , aux.y, aux.z);
                //Debug.Log(aux.y);
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
        else if(_enemy._player.isAlive)
        {
            Vector3 dir = _enemy._player.transform.position - _enemy.transform.position;
            Vector3 aux = dir;
            dir = new Vector3(aux.x, 0f, aux.z);
            _enemy.transform.forward = dir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

            Vector3 transformFix = _enemy.transform.position;
            _enemy.transform.position = new Vector3(transformFix.x, 0.26f, transformFix.z);
            _needsPathfinding = true;
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de PlayerState");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = PathfindingManager.Instance.GetClosestNode(_enemy.transform.position);

        _currentWaypoint = _enemy.GetCurrentWaypoint();
        
        endingPoint = PathfindingManager.Instance.GetClosestNode(_enemy._player.transform.position);

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
    }
}
