using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using static UnityEditor.Experimental.GraphView.GraphView;

public class LivingState : IState
{
    private StateMachine _fsm;
    private Cat _cat;
    private Player _player;
    private int _currentPathWaypoint;
    private List<Transform> _pathToLiving;
    public LivingState(StateMachine fsm, Cat c, Player p)
    {
        _fsm = fsm;
        _cat = c;
        _player = p;
    }

    public void OnExit()
    {
        Debug.Log("Salí de LivingState");
    }

    public void OnStart()
    {
        Debug.Log("Entré a LivingState");
        _cat.OnCatLivingStateFinished += _player.CallCatLivingStateFinished;
        _pathToLiving = _cat.PathToBasement.AsEnumerable().Reverse().ToList();
    }

    public void OnUpdate()
    {
        if (_cat.canMove)
        {
            _cat.EnterWalkingState();

            Vector3 dir = _pathToLiving[_currentPathWaypoint].transform.position - _cat.transform.position;

            Vector3 aux = dir;
            dir = new Vector3(aux.x, aux.y, aux.z);
            _cat.transform.forward = dir;
            _cat.transform.position += _cat.transform.forward * _cat._walkingSpeed * Time.deltaTime;

            if (dir.magnitude < 0.4f)
            {
                _currentPathWaypoint++;
                var last = _pathToLiving.LastOrDefault();
                if (Vector3.Distance(_cat.transform.position, last.transform.position) < 1f)
                {
                    _cat._navMeshAgent.enabled = true;
                    _cat.IsGoingBack = false;
                    GameVars.Values.IsCatBasementStateFinished = true;
                    GameVars.Values.IsUFOExitPlanetAnimFinished = true;
                    _cat.CallLivingStateFinished();
                    _fsm.ChangeCatState(CatStatesEnum.IdleState);
                }
            }
        }
    }
}
