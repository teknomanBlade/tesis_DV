using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HardcodeCatState : IState
{
    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;
    
    public List<Transform> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;

    public HardcodeCatState(StateMachine fsm, Enemy p)
    {
        _fsm = fsm;
        _enemy = p;
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;
        myPath = _enemy.PathHard;
        Debug.Log("Entre a PlayerState");
    }
    public void OnUpdate()
    {
        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.attackThreshold && _enemy._player.isAlive)
        {
            _fsm.ChangeState(EnemyStatesEnum.HardcodeAttackState);
        }

        RaycastHit hit;
        Vector3 playerDir = _enemy._player.transform.position - _enemy.transform.position;                                                                             //Usamos obstacle mask ahora.
        if(myPath != null && Physics.Raycast(_enemy.transform.position, playerDir, out hit, playerDir.magnitude, _enemy.obstacleMask) == true) // || Vector3.Distance(_enemy.transform.position, _enemy._player.transform.position) >= _enemy.pursueThreshold)
        {
            if(myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                Vector3 aux = dir;
                dir = new Vector3 (aux.x , aux.y, aux.z);
                _enemy.transform.forward = dir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

                if (dir.magnitude < 0.4f)
                {
                    _currentPathWaypoint++;
                    if (_currentPathWaypoint > myPath.Count - 1)
                    {
                        Debug.Log("No encontré mi objetivo, recalculando.");
                        //_currentPathWaypoint = 0;
                    }
                }
            }
        }
        else if(_enemy._player.isAlive)
        {
            Vector3 myPos = _enemy.transform.position;
            Vector3 dir = _enemy._player.transform.position - _enemy.transform.position;
            Vector3 aux = dir;
            
            dir = new Vector3(aux.x, 0f, aux.z);
            _enemy.transform.forward = dir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de PlayerState");
    }
}

