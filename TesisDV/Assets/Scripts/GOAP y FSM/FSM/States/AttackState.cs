using System;
using FSM;

public class AttackState : MonoBaseState
{
    public override void UpdateLoop()
    {
        
    }

     public override IState ProcessInput()
    {
       return this;
    }
}
